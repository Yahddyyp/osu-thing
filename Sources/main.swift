import Foundation

let settings = Settings()

let manager = TouchManager(settings: settings)

let interceptor = MouseInterceptor()
interceptor.start()

RunLoop.main.run()
