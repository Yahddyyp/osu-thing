import Foundation

final class MTLoader {
    private static let frameworkPath =
        "/System/Library/PrivateFrameworks/MultitouchSupport.framework/MultitouchSupport"

    private var handle: UnsafeMutableRawPointer?

    var loaded: Bool {
        handle != nil
    }

    init() {
        // clear any previous errors
        dlerror()

        // Attempt to load the MultitouchSupport framework
        handle = dlopen(Self.frameworkPath, RTLD_NOW)
    }

    deinit {
        if let handle {
            dlclose(handle)
        }
    }

    func symbol<T>(named name: String, as type: T.Type) -> T? {
        guard let handle else {
            return nil
        }

        dlerror()

        guard let ptr = dlsym(handle, name) else {
            return nil
        }

        return unsafeBitCast(ptr, to: type)
    }
}
