//
//  MultipeerService.swift
//  Potential Scanner
//
//  근거리 멀티 배틀 통신. MultipeerConnectivity로 서버·계정 없이 기기 직결.
//  - 호스트: advertise(배틀 대기) + 판정 권한
//  - 게스트: browse(호스트 탐색) 후 초대
//  블루투스 의존이라 시뮬레이터/Mac 테스트 불가 — 실기기 2대 필요.
//

@preconcurrency import MultipeerConnectivity
import SwiftUI

/// 기기 간에 오가는 메시지. 호스트가 판정한 BattleOutcome을 게스트에 그대로 보낸다.
enum MultipeerMessage: Codable {
    case card(BattleContender)
    case result(BattleOutcome)
    case rematch
    /// 근거리 링크가 idle로 끊기지 않도록 주기적으로 흘려보내는 유지용 핑. 받는 쪽은 무시.
    case ping
}

@MainActor
@Observable
final class MultipeerService: NSObject {
    enum State: Equatable {
        case idle
        case advertising   // 호스트 대기 중
        case browsing      // 게스트 탐색 중
        case connecting
        case connected
    }

    private static let serviceType = "potscan-btl"

    @ObservationIgnored private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    @ObservationIgnored private lazy var session: MCSession = {
        // 장난감 앱이라 암호화 핸드셰이크 실패로 연결이 안 되는 걸 피하기 위해 .none.
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()

    @ObservationIgnored private var advertiser: MCNearbyServiceAdvertiser?
    @ObservationIgnored private var browser: MCNearbyServiceBrowser?
    @ObservationIgnored private var keepAliveTask: Task<Void, Never>?

    private(set) var state: State = .idle
    private(set) var discoveredPeers: [MCPeerID] = []
    private(set) var connectedPeerName: String?
    /// 게스트가 호스트로부터 결과를 받으므로, 내가 호스트인지 여부로 판정 권한을 가른다.
    private(set) var isHost = false

    var onReceiveMessage: ((MultipeerMessage) -> Void)?

    // MARK: - Host / Guest 시작

    func hostBattle() {
        reset()
        isHost = true
        let advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID, discoveryInfo: nil, serviceType: Self.serviceType
        )
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        self.advertiser = advertiser
        state = .advertising
    }

    func joinBattle() {
        reset()
        isHost = false
        let browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: Self.serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        self.browser = browser
        state = .browsing
    }

    /// 게스트가 발견한 호스트에게 초대를 보낸다.
    func invite(_ peer: MCPeerID) {
        browser?.invitePeer(peer, to: session, withContext: nil, timeout: 20)
        state = .connecting
    }

    // MARK: - 송신

    func send(_ message: MultipeerMessage) {
        guard !session.connectedPeers.isEmpty,
              let data = try? JSONEncoder().encode(message) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    func disconnect() {
        reset()
    }

    private func reset() {
        keepAliveTask?.cancel()
        keepAliveTask = nil
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        advertiser = nil
        browser = nil
        session.disconnect()
        discoveredPeers = []
        connectedPeerName = nil
        state = .idle
    }

    /// 연결 유지용 핑을 주기적으로 흘려 근거리 링크가 idle로 끊기는 걸 막는다.
    private func startKeepAlive() {
        keepAliveTask?.cancel()
        keepAliveTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(1200))
                guard let self, !Task.isCancelled else { break }
                self.send(.ping)
            }
        }
    }
}

// MARK: - MCSessionDelegate

extension MultipeerService: MCSessionDelegate {
    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let name = peerID.displayName
        Task { @MainActor in
            switch state {
            case .connected:
                self.connectedPeerName = name
                self.state = .connected
                self.advertiser?.stopAdvertisingPeer()
                self.browser?.stopBrowsingForPeers()
                self.startKeepAlive()
            case .connecting:
                self.state = .connecting
            case .notConnected:
                // 연결됐다 끊겼거나(.connected) 핸드셰이크 실패(.connecting)면
                // 멈춰있지 않도록 초기화해 재시도할 수 있게 한다.
                if self.state == .connected || self.state == .connecting {
                    self.reset()
                }
            @unknown default:
                break
            }
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        Task { @MainActor in
            guard let message = try? JSONDecoder().decode(MultipeerMessage.self, from: data) else { return }
            self.onReceiveMessage?(message)
        }
    }

    nonisolated func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    nonisolated func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    nonisolated func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate (호스트)

extension MultipeerService: MCNearbyServiceAdvertiserDelegate {
    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        Task { @MainActor in
            // 호스트는 첫 초대를 자동 수락.
            invitationHandler(true, self.session)
        }
    }

    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        Task { @MainActor in self.reset() }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate (게스트)

extension MultipeerService: MCNearbyServiceBrowserDelegate {
    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        Task { @MainActor in
            if !self.discoveredPeers.contains(peerID) {
                self.discoveredPeers.append(peerID)
            }
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        Task { @MainActor in
            self.discoveredPeers.removeAll { $0 == peerID }
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        Task { @MainActor in self.reset() }
    }
}
