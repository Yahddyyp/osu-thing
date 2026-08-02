import Foundation
import Observation

struct ActiveArea: Codable, Equatable {
    var left: Float
    var right: Float
    var top: Float
    var bottom: Float

    //defaults
    static let `default` = ActiveArea(
        left: 0,
        right: 1,
        top: 0,
        bottom: 1
    )
}

// For disable absolute tracking when ajusting settings
enum DriverState {
    case editing
    case enable
    case disable
}

@Observable
final class Settings {
    var driverState: DriverState = .editing
    var enable = true
    var activeArea = ActiveArea.default

}

extension Settings: @unchecked Sendable {}
