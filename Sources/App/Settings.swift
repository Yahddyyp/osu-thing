import Foundation
import Observation

struct ActiveArea: Codable, Equatable {
    var left: Float
    var right: Float
    var top: Float
    var bottom: Float

    static let `default` = ActiveArea(
        left: 0,
        right: 1,
        top: 0,
        bottom: 1
    )
}

@Observable
final class Settings {
    var enable = true
    var activeArea = ActiveArea.default
}

extension Settings: @unchecked Sendable {}
