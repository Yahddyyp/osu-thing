import Foundation

final class TouchManager {
    private let loader = MTLoader()

    private static let currentLock = NSLock()
    nonisolated(unsafe) private static weak var _current: TouchManager?

    private let mapper = CoordinateMapper()
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

    init() {
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
                    as: MTRegisterContactFrameCallbackFn.self)
        else {
            print("Couldn't resolve MTRegisterContactFrameCallback")
            return
        }

        print("MTDeviceCreateList resolved!")
        guard let devicesArray = createList()?.takeRetainedValue() else {
            print("No trackpads found")
            return
        }
        let count = CFArrayGetCount(devicesArray)
        print("Found \(count) devices")
        guard count > 0, let rawDevice = CFArrayGetValueAtIndex(devicesArray, 0) else {
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
        guard let fingers, count > 0 else {
            return
        }

        let finger = fingers[0]

        let point = mapper.map(
            x: finger.normalized.position.x,
            y: finger.normalized.position.y
        )

        cursor.move(to: point)
    }
}
