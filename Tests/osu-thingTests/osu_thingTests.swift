import CoreGraphics
import Testing

@testable import osu_thing

private func expectClose(
    _ actual: Float,
    _ expected: Float,
    tolerance: Float = 1e-5,
    comment: Comment? = nil,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(abs(actual - expected) <= tolerance, comment, sourceLocation: sourceLocation)
}

@Test("Config decodes legacy JSON without new fields")
func configDecodesLegacyJSON() throws {
    let legacy = """
    {
        "activeArea": {
            "left": 0.1,
            "right": 0.9,
            "minY": 0.2,
            "maxY": 0.8
        }
    }
    """

    let config = try JSONDecoder().decode(Config.self, from: Data(legacy.utf8))

    #expect(config.automaticEnable == false)
    #expect(config.lockAspectRatio == false)
    #expect(config.activeArea == ActiveArea(left: 0.1, right: 0.9, minY: 0.2, maxY: 0.8))
}

@Test("Config round-trips all fields through encode/decode")
func configRoundTripsAllFields() throws {
    let config = Config(
        activeArea: ActiveArea(left: 0.25, right: 0.75, minY: 0.25, maxY: 0.75),
        automaticEnable: true,
        lockAspectRatio: true
    )

    let data = try JSONEncoder().encode(config)
    let decoded = try JSONDecoder().decode(Config.self, from: data)

    #expect(decoded.automaticEnable == true)
    #expect(decoded.lockAspectRatio == true)
    #expect(decoded.activeArea == config.activeArea)
}

@Test("UIRect ↔ ActiveArea round-trips without drift")
func uiRectRoundTrips() {
    let areas: [ActiveArea] = [
        .default,
        ActiveArea(left: 0.1, right: 0.9, minY: 0.2, maxY: 0.8),
        ActiveArea(left: 0.25, right: 0.75, minY: 0.3, maxY: 0.7),
        ActiveArea(left: 0.6, right: 0.999, minY: 0.001, maxY: 0.5),
    ]
    let size = CGSize(width: 400, height: 250)

    for area in areas {
        let rect = makeUIRect(from: area, size: size)
        let roundTripped = makeActiveArea(from: rect, size: size)

        expectClose(roundTripped.left, area.left)
        expectClose(roundTripped.right, area.right)
        expectClose(roundTripped.minY, area.minY)
        expectClose(roundTripped.maxY, area.maxY)
    }
}

@Test("trackpad y maps to SwiftUI y with flip")
func uiRectConvertsTrackpadYToSwiftUIY() {
    let size = CGSize(width: 400, height: 200)
    let area = ActiveArea(left: 0.25, right: 0.75, minY: 0.25, maxY: 0.75)

    let rect = makeUIRect(from: area, size: size)

    #expect(rect.left == 100)
    #expect(rect.right == 300)
    #expect(rect.top == 50)
    #expect(rect.bottom == 150)
}

@Test("translating the rect clamps to the view bounds")
func translationKeepsRectInsideBounds() {
    let size = CGSize(width: 400, height: 200)
    let rect = UIRect(left: 100, top: 50, right: 300, bottom: 150)

    let moved = rect.translated(by: CGSize(width: 1000, height: 1000), in: size)
    #expect(moved.left == 200)
    #expect(moved.right == 400)
    #expect(moved.top == 100)
    #expect(moved.bottom == 200)

    let movedBack = rect.translated(by: CGSize(width: -1000, height: -1000), in: size)
    #expect(movedBack.left == 0)
    #expect(movedBack.right == 200)
    #expect(movedBack.top == 0)
    #expect(movedBack.bottom == 100)
}

@Test("resizing clamps edges to the view bounds")
func resizeClampsEdgesToBounds() {
    let size = CGSize(width: 400, height: 200)
    let rect = UIRect(left: 100, top: 50, right: 300, bottom: 150)

    // Top-left dragged far past the corner
    let tl = rect.resized(from: .topLeft, by: CGSize(width: -1000, height: -1000), in: size)
    #expect(tl.left == 0)
    #expect(tl.top == 0)
    #expect(tl.right == 300)
    #expect(tl.bottom == 150)

    let br = rect.resized(from: .bottomRight, by: CGSize(width: 1000, height: 1000), in: size)
    #expect(br.left == 100)
    #expect(br.top == 50)
    #expect(br.right == 400)
    #expect(br.bottom == 200)
}

@Test("resizing cannot invert or fully collapse an edge")
func resizeKeepsMinSize() {
    let size = CGSize(width: 400, height: 200)
    let rect = UIRect(left: 100, top: 50, right: 300, bottom: 150)

    let collapsed = rect.resized(from: .topRight, by: CGSize(width: -1000, height: 0), in: size)
    #expect(collapsed.right == collapsed.left + 1)
    #expect(collapsed.left == 100)
}

@Test("translation + convert-back produces the expected area")
func translateThenConvertBack() {
    let size = CGSize(width: 400, height: 200)
    let area = ActiveArea(left: 0.25, right: 0.75, minY: 0.25, maxY: 0.75)
    let rect = makeUIRect(from: area, size: size)

    let moved = rect.translated(by: CGSize(width: 40, height: 20), in: size)
    let result = makeActiveArea(from: moved, size: size)

    expectClose(result.left, 0.35)
    expectClose(result.right, 0.85)
    expectClose(result.maxY, 0.65)
    expectClose(result.minY, 0.15)
}
