import Foundation

final class MTLoader {
    private static let frameworkPath =
        "/System/Library/PrivateFrameworks/MultitouchSupport.framework/MultitouchSupport"

    private var handle: UnsafeMutableRawPointer?

    var loaded: Bool {
        handle != nil
    }

    init() {
        //clear previous errors
        dlerror()
        handle = dlopen(Self.frameworkPath, RTLD_NOW)

        if handle == nil {
            if let error = dlerror() {
                print("Failed to load framework \(Self.frameworkPath)")
                print(String(cString: error))

            }
        } else {
            print("Successfully loaded MultitouchSupport!")
        }
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
            if let error = dlerror() {
                print("Failed to resolve symbol '\(name)':")
                print(String(cString: error))
            }
            return nil
        }

        return unsafeBitCast(ptr, to: type)
    }
}
