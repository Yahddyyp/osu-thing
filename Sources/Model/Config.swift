import Foundation

struct Config: Codable {
    var activeArea: ActiveArea

    static let `default` = Config(
        activeArea: .default
    )
}
