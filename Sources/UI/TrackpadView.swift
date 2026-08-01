import SwiftUI

private enum Corner {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

struct TrackpadView: View {
    let settings: Settings
    let touchState: TouchState
    @Binding var area: ActiveArea

    @State private var dragStartArea: ActiveArea?

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let left = CGFloat(area.left) * width
            let right = CGFloat(area.right) * width

            let top = CGFloat(area.top) * height
            let bottom = CGFloat(area.bottom) * height

            ZStack {

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))

                RoundedRectangle(cornerRadius: 20)
                    .stroke(.gray, lineWidth: 2)

                RoundedRectangle(cornerRadius: 8)
                    .stroke(.blue, lineWidth: 3)
                    .frame(
                        width: right - left,
                        height: bottom - top
                    )
                    .position(
                        x: (left + right) / 2,
                        y: (top + bottom) / 2
                    )
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in

                                if dragStartArea == nil {
                                    dragStartArea = area
                                }

                                guard let start = dragStartArea else {
                                    return
                                }

                                let dx = Float(value.translation.width / width)
                                let dy = Float(value.translation.height / height)

                                let rectWidth = start.right - start.left
                                let rectHeight = start.bottom - start.top

                                let newLeft = min(
                                    max(start.left + dx, 0),
                                    1 - rectWidth
                                )

                                let newTop = min(
                                    max(start.top + dy, 0),
                                    1 - rectHeight
                                )

                                area.left = newLeft
                                area.right = newLeft + rectWidth

                                area.top = newTop
                                area.bottom = newTop + rectHeight
                            }
                            .onEnded { _ in
                                dragStartArea = nil
                            }
                    )

                handle(
                    corner: .topLeft,
                    x: left,
                    y: top,
                    width: width,
                    height: height
                )

                handle(
                    corner: .topRight,
                    x: right,
                    y: top,
                    width: width,
                    height: height
                )

                handle(
                    corner: .bottomLeft,
                    x: left,
                    y: bottom,
                    width: width,
                    height: height
                )

                handle(
                    corner: .bottomRight,
                    x: right,
                    y: bottom,
                    width: width,
                    height: height
                )

                if let finger = touchState.finger {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                        .position(
                            x: CGFloat(finger.x) * width,
                            y: (1 - CGFloat(finger.y)) * height
                        )
                }

                VStack {
                    Text(
                        touchState.finger.map {
                            String(format: "(%.3f, %.3f)", $0.x, $0.y)
                        } ?? "no finger"
                    )
                    .foregroundStyle(.red)

                    Spacer()
                }
                .padding(.top, 12)
            }
        }
        .aspectRatio(1.6, contentMode: .fit)
    }

    @ViewBuilder
    private func handle(
        corner: Corner,
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) -> some View {

        Circle()
            .fill(.blue)
            .frame(width: 18, height: 18)
            .contentShape(Rectangle())
            .position(x: x, y: y)
            .gesture(
                DragGesture()
                    .onChanged { value in

                        if dragStartArea == nil {
                            dragStartArea = area
                        }

                        guard let start = dragStartArea else {
                            return
                        }

                        let dx = Float(value.translation.width / width)
                        let dy = Float(value.translation.height / height)

                        switch corner {

                        case .topLeft:
                            area.left = min(
                                max(start.left + dx, 0),
                                start.right
                            )

                            area.top = min(
                                max(start.top + dy, 0),
                                start.bottom
                            )

                        case .topRight:
                            area.right = max(
                                min(start.right + dx, 1),
                                start.left
                            )

                            area.top = min(
                                max(start.top + dy, 0),
                                start.bottom
                            )

                        case .bottomLeft:
                            area.left = min(
                                max(start.left + dx, 0),
                                start.right
                            )

                            area.bottom = max(
                                min(start.bottom + dy, 1),
                                start.top
                            )

                        case .bottomRight:
                            area.right = max(
                                min(start.right + dx, 1),
                                start.left
                            )

                            area.bottom = max(
                                min(start.bottom + dy, 1),
                                start.top
                            )
                        }
                    }
                    .onEnded { _ in
                        dragStartArea = nil
                    }
            )
    }
}
