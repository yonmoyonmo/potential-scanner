//
//  AffinityFamily.swift
//  Potential Scanner
//
//  배틀 상성. 108종 타입을 나루토 차크라 속성 11계열에 테마별로 몰아넣고,
//  계열을 "링"으로 배열해 각 계열이 바로 옆(다음 2개)만 이기게 한다.
//  → 각 계열이 2개를 이기고 2개에 지고 나머지 6개엔 무관 = 상성 발동 약 36%.
//
//  이 계열은 UI에 노출하지 않는다(은닉 상성). 배틀 판정에만 쓰이고,
//  사용자에겐 "{타입}이 {타입}에 효과적" 식의 문구로만 결과가 드러난다.
//

import Foundation

enum AffinityFamily: CaseIterable {
    // 배열 순서 = 상성 링 순서. 각 계열은 자기 다음 2개를 이긴다.
    // 나루토 정식 오행(화>풍>뇌>토>수>화)을 최대한 보존하도록 조합속성을 사이에 끼웠다.
    case fire        // 화둔
    case lava        // 용둔
    case wind        // 풍둔
    case magnet      // 자둔
    case lightning   // 뇌둔
    case superMagnet // 초자둔
    case explosion   // 폭둔
    case earth       // 토둔
    case wood        // 목둔
    case water       // 수둔
    case ice         // 빙둔

    private var ringIndex: Int {
        AffinityFamily.allCases.firstIndex(of: self)!
    }

    /// self가 other를 상성으로 이기는가 (링에서 다음 2칸 안에 있으면 우위).
    func beats(_ other: AffinityFamily) -> Bool {
        let count = AffinityFamily.allCases.count
        let distance = (other.ringIndex - ringIndex + count) % count
        return distance == 1 || distance == 2
    }
}

extension PotentialType {
    /// 이 타입이 속한 은닉 상성 계열.
    var affinityFamily: AffinityFamily {
        AffinityFamily.family(forTypeID: id)
    }
}

extension AffinityFamily {
    static func family(forTypeID id: String) -> AffinityFamily {
        familyByTypeID[id] ?? .earth
    }

    /// 포켓몬 18종 + D&D 계열 20종 → 11계열 테마 매핑.
    private static let familyByTypeID: [String: AffinityFamily] = [
        // 포켓몬
        "pokemon.normal": .earth, "pokemon.fire": .fire, "pokemon.water": .water,
        "pokemon.grass": .wood, "pokemon.electric": .lightning, "pokemon.ice": .ice,
        "pokemon.fighting": .explosion, "pokemon.poison": .magnet, "pokemon.ground": .earth,
        "pokemon.flying": .wind, "pokemon.psychic": .superMagnet, "pokemon.bug": .wood,
        "pokemon.rock": .earth, "pokemon.ghost": .superMagnet, "pokemon.dragon": .lava,
        "pokemon.dark": .magnet, "pokemon.steel": .magnet, "pokemon.fairy": .superMagnet,
        // D&D 성향
        "dnd_alignment.lg": .earth, "dnd_alignment.ng": .wood, "dnd_alignment.cg": .fire,
        "dnd_alignment.ln": .magnet, "dnd_alignment.tn": .superMagnet, "dnd_alignment.cn": .wind,
        "dnd_alignment.le": .lava, "dnd_alignment.ne": .ice, "dnd_alignment.ce": .explosion,
        // D&D 종족
        "dnd_race.human": .earth, "dnd_race.elf": .wood, "dnd_race.dwarf": .earth,
        "dnd_race.halfling": .wind, "dnd_race.gnome": .lightning, "dnd_race.orc": .explosion,
        // D&D 속성피해
        "dnd_damage.acid": .water, "dnd_damage.cold": .ice, "dnd_damage.fire": .fire,
        "dnd_damage.lightning": .lightning, "dnd_damage.wind": .wind,
        // 에겐-테토
        "egen_teto.egen": .water, "egen_teto.teto": .fire,
        // 기타(misc)
        "misc.musician": .wind, "misc.lawyer": .earth, "misc.comedian": .explosion,
        "misc.idol": .superMagnet, "misc.actor": .fire, "misc.lie": .magnet,
        "misc.magic": .superMagnet, "misc.picky_eater": .wood, "misc.farter": .explosion,
        "misc.genius": .lightning, "misc.airhead": .earth, "misc.peace": .wind,
        "misc.love": .superMagnet, "misc.light": .fire, "misc.darkness": .magnet,
        "misc.otaku": .wood, "misc.flower": .wood, "misc.plant": .wood,
        "misc.know_it_all": .earth, "misc.premium": .magnet, "misc.lowbrow": .explosion,
        "misc.young_trendy": .wind, "misc.old_trendy": .earth,
        // 음식
        "food.spicy": .fire, "food.mukbang": .explosion,
        // 동물상
        "animal.cat": .ice, "animal.dog": .fire,
        // 게임 롤
        "game.tank": .earth, "game.dealer": .explosion,
        // 세대 트렌드
        "trend.mzeong": .wind,
        // 계절
        "season.spring": .wood, "season.summer": .fire,
        "season.autumn": .wind, "season.winter": .ice,
    ]
}
