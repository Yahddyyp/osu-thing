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
        activeArea = ConfigManager.load().activeArea
    }

    func save() {
        try? ConfigManager.save(
            Config(activeArea: activeArea)
        )
    }
}

extension Settings: @unchecked Sendable {}
