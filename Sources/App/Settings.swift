import Foundation
import Observation

struct ActiveArea: Codable, Equatable {
    var left: Float
    var right: Float

    var minY: Float
    var maxY: Float

    // defaults
    static let `default` = ActiveArea(
        left: 0,
        right: 1,
        minY: 0,
        maxY: 1
    )
}

// For disabling absolute tracking when adjusting settings
enum DriverState {
    case editing
    case enable
    case disable
}

@Observable
final class Settings {
    // settings
    var driverState: DriverState = .editing
    var activeArea: ActiveArea
    var automaticEnable = false
    var lockAspectRatio = false

    init() {
        let config = ConfigManager.load()
        activeArea = config.activeArea
        automaticEnable = config.automaticEnable
        lockAspectRatio = config.lockAspectRatio
    }

    func save() {
        try? ConfigManager.save(
            Config(
                activeArea: activeArea,
                automaticEnable: automaticEnable,
                lockAspectRatio: lockAspectRatio
            )
        )
    }
}

extension Settings: @unchecked Sendable {}
