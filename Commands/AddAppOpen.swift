import Foundation

class AddAppOpen {
  var keyCode: String
  var appName: String

  init(keyCode: String, appName: String) {
    self.keyCode = keyCode
    self.appName = appName
  }
  func run() {
    print("add app open")
  }
}