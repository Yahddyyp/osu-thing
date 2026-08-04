import Foundation

enum ConfigManager {

    private static let directory =
        FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".config")
        .appendingPathComponent("osu-thing")

    private static let file =
        directory.appendingPathComponent("config.json")

    static func load() -> Config {

        guard
            let data = try? Data(contentsOf: file),
            let config = try? JSONDecoder().decode(
                Config.self,
                from: data
            )
        else {
            return .default
        }

        return config
    }

    static func save(_ config: Config) throws {

        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        let data = try encoder.encode(config)

        try data.write(to: file)
    }
}
