import Foundation

final class TouchManager {
    private let settings: Settings
    private let touchState: TouchState
    private let loader = MTLoader()

    private static let currentLock = NSLock()
    nonisolated(unsafe) private static weak var _current: TouchManager?

    private let mapper: CoordinateMapper
    private let cursor = CursorController()

    private static var current: TouchManager? {
        get {
            currentLock.lock()
            defer { currentLock.unlock() }
            return _current
        }
        set {
            currentLock.lock()
            defer { currentLock.unlock() }
            _current = newValue
        }
    }

    private static let contactCallback: MTContactCallback = {
        device, dataPtr, nFingers, timestamp, frameID in

        let fingers = dataPtr?.assumingMemoryBound(to: Finger.self)

        TouchManager.current?.handleContactFrame(
            fingers: fingers,
            count: Int(nFingers)
        )

        return 0
    }

    private var registerCallback: MTRegisterContactFrameCallbackFn?
    private var startDevice: MTDeviceStartFn?
    private var device: UnsafeMutableRawPointer?

    init(settings: Settings, touchState: TouchState) {
        self.settings = settings
        self.touchState = touchState
        self.mapper = CoordinateMapper(settings: settings)

        guard
            let createList: MTDeviceCreateListFn =
                loader.symbol(named: "MTDeviceCreateList", as: MTDeviceCreateListFn.self)
        else {
            print("Couldn't resolve MTDeviceCreateList")
            return
        }

        guard
            let start: MTDeviceStartFn =
                loader.symbol(named: "MTDeviceStart", as: MTDeviceStartFn.self)
        else {
            print("Couldn't resolve MTDeviceStart")
            return
        }

        guard
            let register: MTRegisterContactFrameCallbackFn =
                loader.symbol(
                    named: "MTRegisterContactFrameCallback",
                    as: MTRegisterContactFrameCallbackFn.self
                )
        else {
            print("Couldn't resolve MTRegisterContactFrameCallback")
            return
        }

        guard let devicesArray = createList()?.takeRetainedValue() else {
            print("No trackpads found")
            return
        }

        let count = CFArrayGetCount(devicesArray)

        guard
            count > 0,
            let rawDevice = CFArrayGetValueAtIndex(devicesArray, 0)
        else {
            print("No trackpads found")
            return
        }

        self.device = UnsafeMutableRawPointer(mutating: rawDevice)
        self.startDevice = start
        self.registerCallback = register

        TouchManager.current = self

        register(self.device!, TouchManager.contactCallback)
        start(self.device!, 0)
    }

    private func handleContactFrame(
        fingers: UnsafeMutablePointer<Finger>?,
        count: Int
    ) {
        guard settings.driverState == .enabling else {
            return
        }

        guard let fingers, count > 0 else {
            DispatchQueue.main.async { @MainActor [touchState] in
                touchState.finger = nil
            }
            return
        }

        let finger = fingers[0]

        let x = finger.normalized.position.x
        let y = finger.normalized.position.y

        DispatchQueue.main.async { @MainActor [touchState] in
            touchState.finger = TouchPoint(x: x, y: y)
        }

        let point = mapper.map(
            x: x,
            y: y
        )

        cursor.move(to: point)
    }
}
