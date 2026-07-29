import Foundation

typealias MTDeviceCreateListFn = @convention(c) () -> Unmanaged<CFArray>?
typealias MTRegisterContactFrameCallbackFn =
    @convention(c) (UnsafeMutableRawPointer, MTContactCallback) -> Void
typealias MTDeviceStartFn = @convention(c) (UnsafeMutableRawPointer, Int32) -> Void
