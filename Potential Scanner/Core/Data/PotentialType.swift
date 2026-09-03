//
//  PotentialType.swift
//  Potential Scanner
//
//  콘텐츠.md "1. 타입 목록" 108종을 그대로 옮김. 이름/설명 실제 텍스트는
//  Localizable.xcstrings에 있고, 여기서는 안정적인 id만 관리한다.
//

import Foundation

struct PotentialType: Identifiable, Hashable {
    let id: String
    let seriesID: String

    var nameKey: String { "type.\(id).name" }
    var descriptionKey: String { "type.\(id).description" }

    var name: String { String(localized: String.LocalizationValue(nameKey)) }
    var description: String { String(localized: String.LocalizationValue(descriptionKey)) }

    /// "불의 호흡 타입" / "Fire Breathing Type" / "水の呼吸タイプ" 처럼 항상 붙는 "타입" 접미사 포함 표기.
    var displayLabel: String {
        "\(name) \(String(localized: String.LocalizationValue("ui.type.suffix")))"
    }
}

extension PotentialType {
    private static let byID: [String: PotentialType] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.id, $0) }
    )

    /// 저장된 카드에 박혀있는 typeID로 원래 타입을 역으로 찾는다.
    static func find(byID id: String) -> PotentialType? {
        byID[id]
    }
}

extension PotentialType {
    /// 포켓몬 18종 + D&D 계열(성향/종족/속성피해) 20종 타입 풀.
    static let all: [PotentialType] = [
        // pokemon (18)
        PotentialType(id: "pokemon.normal", seriesID: "pokemon"),
        PotentialType(id: "pokemon.fire", seriesID: "pokemon"),
        PotentialType(id: "pokemon.water", seriesID: "pokemon"),
        PotentialType(id: "pokemon.grass", seriesID: "pokemon"),
        PotentialType(id: "pokemon.electric", seriesID: "pokemon"),
        PotentialType(id: "pokemon.ice", seriesID: "pokemon"),
        PotentialType(id: "pokemon.fighting", seriesID: "pokemon"),
        PotentialType(id: "pokemon.poison", seriesID: "pokemon"),
        PotentialType(id: "pokemon.ground", seriesID: "pokemon"),
        PotentialType(id: "pokemon.flying", seriesID: "pokemon"),
        PotentialType(id: "pokemon.psychic", seriesID: "pokemon"),
        PotentialType(id: "pokemon.bug", seriesID: "pokemon"),
        PotentialType(id: "pokemon.rock", seriesID: "pokemon"),
        PotentialType(id: "pokemon.ghost", seriesID: "pokemon"),
        PotentialType(id: "pokemon.dragon", seriesID: "pokemon"),
        PotentialType(id: "pokemon.dark", seriesID: "pokemon"),
        PotentialType(id: "pokemon.steel", seriesID: "pokemon"),
        PotentialType(id: "pokemon.fairy", seriesID: "pokemon"),
        // dnd_alignment (9)
        PotentialType(id: "dnd_alignment.lg", seriesID: "dnd_alignment"),
        PotentialType(id: "dnd_alignment.ng", seriesID: "dnd_alignment"),
        PotentialType(id: "dnd_alignment.cg", seriesID: "dnd_alignment"),
        PotentialType(id: "dnd_alignment.ln", seriesID: "dnd_alignment"),
        PotentialType(id: "dnd_alignment.tn", seriesID: "dnd_alignment"),
        PotentialType(id: "dnd_alignment.cn", seriesID: "dnd_alignment"),
        PotentialType(id: "dnd_alignment.le", seriesID: "dnd_alignment"),
        PotentialType(id: "dnd_alignment.ne", seriesID: "dnd_alignment"),
        PotentialType(id: "dnd_alignment.ce", seriesID: "dnd_alignment"),
        // dnd_race (6)
        PotentialType(id: "dnd_race.human", seriesID: "dnd_race"),
        PotentialType(id: "dnd_race.elf", seriesID: "dnd_race"),
        PotentialType(id: "dnd_race.dwarf", seriesID: "dnd_race"),
        PotentialType(id: "dnd_race.halfling", seriesID: "dnd_race"),
        PotentialType(id: "dnd_race.gnome", seriesID: "dnd_race"),
        PotentialType(id: "dnd_race.orc", seriesID: "dnd_race"),
        // dnd_damage (5)
        PotentialType(id: "dnd_damage.acid", seriesID: "dnd_damage"),
        PotentialType(id: "dnd_damage.cold", seriesID: "dnd_damage"),
        PotentialType(id: "dnd_damage.fire", seriesID: "dnd_damage"),
        PotentialType(id: "dnd_damage.lightning", seriesID: "dnd_damage"),
        PotentialType(id: "dnd_damage.wind", seriesID: "dnd_damage"),
        // egen_teto (2)
        PotentialType(id: "egen_teto.egen", seriesID: "egen_teto"),
        PotentialType(id: "egen_teto.teto", seriesID: "egen_teto"),
        // misc (23)
        PotentialType(id: "misc.musician", seriesID: "misc"),
        PotentialType(id: "misc.lawyer", seriesID: "misc"),
        PotentialType(id: "misc.comedian", seriesID: "misc"),
        PotentialType(id: "misc.idol", seriesID: "misc"),
        PotentialType(id: "misc.actor", seriesID: "misc"),
        PotentialType(id: "misc.lie", seriesID: "misc"),
        PotentialType(id: "misc.magic", seriesID: "misc"),
        PotentialType(id: "misc.picky_eater", seriesID: "misc"),
        PotentialType(id: "misc.farter", seriesID: "misc"),
        PotentialType(id: "misc.genius", seriesID: "misc"),
        PotentialType(id: "misc.airhead", seriesID: "misc"),
        PotentialType(id: "misc.peace", seriesID: "misc"),
        PotentialType(id: "misc.love", seriesID: "misc"),
        PotentialType(id: "misc.light", seriesID: "misc"),
        PotentialType(id: "misc.darkness", seriesID: "misc"),
        PotentialType(id: "misc.otaku", seriesID: "misc"),
        PotentialType(id: "misc.flower", seriesID: "misc"),
        PotentialType(id: "misc.plant", seriesID: "misc"),
        PotentialType(id: "misc.know_it_all", seriesID: "misc"),
        PotentialType(id: "misc.premium", seriesID: "misc"),
        PotentialType(id: "misc.lowbrow", seriesID: "misc"),
        PotentialType(id: "misc.young_trendy", seriesID: "misc"),
        PotentialType(id: "misc.old_trendy", seriesID: "misc"),
        // food (2)
        PotentialType(id: "food.spicy", seriesID: "food"),
        PotentialType(id: "food.mukbang", seriesID: "food"),
        // animal (2)
        PotentialType(id: "animal.cat", seriesID: "animal"),
        PotentialType(id: "animal.dog", seriesID: "animal"),
        // game (2)
        PotentialType(id: "game.tank", seriesID: "game"),
        PotentialType(id: "game.dealer", seriesID: "game"),
        // trend (1)
        PotentialType(id: "trend.mzeong", seriesID: "trend"),
        // season (4)
        PotentialType(id: "season.spring", seriesID: "season"),
        PotentialType(id: "season.summer", seriesID: "season"),
        PotentialType(id: "season.autumn", seriesID: "season"),
        PotentialType(id: "season.winter", seriesID: "season"),
    ]
}
