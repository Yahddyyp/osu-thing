import Foundation

struct Config: Codable {
    var activeArea: ActiveArea
    var automaticEnable: Bool
    var lockAspectRatio: Bool

    static let `default` = Config(
        activeArea: .default,
        automaticEnable: false,
        lockAspectRatio: false
    )

    init(
        activeArea: ActiveArea,
        automaticEnable: Bool,
        lockAspectRatio: Bool
    ) {
        self.activeArea = activeArea
        self.automaticEnable = automaticEnable
        self.lockAspectRatio = lockAspectRatio
    }

    // Decode leniently so config files written by older versions
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        activeArea = try container.decode(ActiveArea.self, forKey: .activeArea)
        automaticEnable =
            try container.decodeIfPresent(Bool.self, forKey: .automaticEnable) ?? false
        lockAspectRatio =
            try container.decodeIfPresent(Bool.self, forKey: .lockAspectRatio) ?? false
    }
}
