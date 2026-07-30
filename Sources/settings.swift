import Foundation

// The area to use for the input
struct ActiveArea {
    var left: Float
    var right: Float
    var top: Float
    var bottom: Float
}

// The settings for the activeArea
struct Settings {
    var activeArea = ActiveArea(
        left: 0.25,
        right: 0.75,
        top: 0.25,
        bottom: 0.75
    )
}
