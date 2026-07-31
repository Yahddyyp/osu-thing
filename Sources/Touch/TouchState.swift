import Foundation
import Observation

struct TouchPoint {
    var x: Float
    var y: Float
}

@MainActor
@Observable
final class TouchState {
    var finger: TouchPoint?
}
