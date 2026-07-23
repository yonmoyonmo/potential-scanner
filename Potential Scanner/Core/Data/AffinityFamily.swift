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

    /// 108종 → 11계열 테마 매핑. (원작 상성이 있는 포켓몬/차크라/귀멸은 직관적으로,
    /// MBTI·혈액형·별자리 등 무속성류는 성격 뉘앙스로 배정)
    private static let familyByTypeID: [String: AffinityFamily] = [
        // 포켓몬
        "pokemon.normal": .earth, "pokemon.fire": .fire, "pokemon.water": .water,
        "pokemon.grass": .wood, "pokemon.electric": .lightning, "pokemon.ice": .ice,
        "pokemon.fighting": .explosion, "pokemon.poison": .magnet, "pokemon.ground": .earth,
        "pokemon.flying": .wind, "pokemon.psychic": .superMagnet, "pokemon.bug": .wood,
        "pokemon.rock": .earth, "pokemon.ghost": .superMagnet, "pokemon.dragon": .lava,
        "pokemon.dark": .magnet, "pokemon.steel": .magnet, "pokemon.fairy": .superMagnet,
        // 헌터 넨
        "nen.enhancer": .earth, "nen.emitter": .explosion, "nen.manipulator": .magnet,
        "nen.transmuter": .water, "nen.specialist": .superMagnet, "nen.conjurer": .wood,
        // 원피스
        "onepiece.paramecia": .explosion, "onepiece.logia": .water, "onepiece.zoan": .wood,
        // 귀멸 호흡
        "breath.sun": .fire, "breath.water": .water, "breath.flame": .fire,
        "breath.wind": .wind, "breath.stone": .earth, "breath.thunder": .lightning,
        "breath.love": .magnet, "breath.serpent": .water, "breath.mist": .ice,
        "breath.sound": .lightning, "breath.insect": .wood, "breath.beast": .explosion,
        "breath.flower": .wood, "breath.moon": .superMagnet,
        // 나루토 차크라 (직접 매핑)
        "chakra.fire": .fire, "chakra.water": .water, "chakra.wind": .wind,
        "chakra.lightning": .lightning, "chakra.earth": .earth, "chakra.ice": .ice,
        "chakra.wood": .wood, "chakra.lava": .lava, "chakra.explosion": .explosion,
        "chakra.magnet": .magnet, "chakra.supermagnet": .superMagnet,
        // MBTI
        "mbti.istj": .earth, "mbti.isfj": .wood, "mbti.infj": .superMagnet,
        "mbti.intj": .magnet, "mbti.istp": .explosion, "mbti.isfp": .ice,
        "mbti.infp": .water, "mbti.intp": .superMagnet, "mbti.estp": .lightning,
        "mbti.esfp": .fire, "mbti.enfp": .fire, "mbti.entp": .wind,
        "mbti.estj": .earth, "mbti.esfj": .wood, "mbti.enfj": .magnet, "mbti.entj": .explosion,
        // 혈액형
        "blood.a": .earth, "blood.b": .wind, "blood.o": .fire, "blood.ab": .superMagnet,
        // 사상의학
        "sasang.taeyang": .fire, "sasang.taeeum": .earth, "sasang.soyang": .lightning,
        "sasang.soeum": .water,
        // 십이지신
        "zodiac12.rat": .lightning, "zodiac12.ox": .earth, "zodiac12.tiger": .fire,
        "zodiac12.rabbit": .wind, "zodiac12.dragon": .lava, "zodiac12.snake": .magnet,
        "zodiac12.horse": .wind, "zodiac12.goat": .wood, "zodiac12.monkey": .explosion,
        "zodiac12.rooster": .superMagnet, "zodiac12.dog": .earth, "zodiac12.pig": .wood,
        // 별자리
        "constellation.aries": .fire, "constellation.taurus": .earth, "constellation.gemini": .wind,
        "constellation.cancer": .water, "constellation.leo": .fire, "constellation.virgo": .earth,
        "constellation.libra": .wind, "constellation.scorpio": .magnet,
        "constellation.sagittarius": .explosion, "constellation.capricorn": .earth,
        "constellation.aquarius": .superMagnet, "constellation.pisces": .water,
        // 에겐-테토
        "egen_teto.egen": .water, "egen_teto.teto": .explosion,
        // 관상
        "physiognomy.dog": .fire, "physiognomy.cat": .ice, "physiognomy.fox": .wind,
        "physiognomy.bear": .earth, "physiognomy.rabbit": .wood, "physiognomy.deer": .ice,
    ]
}
