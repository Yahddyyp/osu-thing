import SwiftUI

// The red dot and readout showing where the finger currently is.
struct FingerIndicator: View {
    let finger: TouchPoint?
    let size: CGSize

    var body: some View {
        ZStack {
            if let finger {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)
                    .position(
                        x: CGFloat(finger.x) * size.width,
                        y: (1 - CGFloat(finger.y)) * size.height
                    )
            }

            VStack {
                Text(
                    finger.map {
                        String(format: "(%.3f, %.3f)", $0.x, $0.y)
                    } ?? "no finger"
                )
                .foregroundStyle(.red)

                Spacer()
            }
            .padding(.top, 12)
        }
    }
}
