import SwiftUI

struct TrackpadView: View {
    let settings: Settings
    let touchState: TouchState
    @Binding var area: ActiveArea

    @State private var stateBeforeDrag: DriverState?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ActiveAreaOverlay(
                    area: $area,
                    size: geometry.size,
                    onDragBegan: beginDrag,
                    onDragEnded: endDrag
                )

                FingerIndicator(
                    finger: touchState.finger,
                    size: geometry.size
                )
            }
        }
        .frame(width: 350, height: 350 / 1.6)
    }

    private func beginDrag() {
        if stateBeforeDrag == nil {
            stateBeforeDrag = settings.driverState
            settings.driverState = .editing
        }
    }

    private func endDrag() {
        if let state = stateBeforeDrag {
            settings.driverState = state
        }
        stateBeforeDrag = nil
    }
}
