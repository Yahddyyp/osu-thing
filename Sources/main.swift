import Foundation

let manager = TouchManager()

let interceptor = MouseInterceptor()
interceptor.start()

RunLoop.main.run()
