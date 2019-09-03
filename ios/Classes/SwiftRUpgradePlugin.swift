import Flutter
import UIKit

public class SwiftRUpgradePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "r_upgrade", binaryMessenger: registrar.messenger())
    let instance = SwiftRUpgradePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "upgradeFromAppStore":
            print(call.arguments ?? "null")
            guard let urlString = (call.arguments as? Dictionary<String, Any>)?["url"] as? String else {
                result(FlutterError(code: "参数url不能为空", message: nil, details: nil))
                return
            }
            gotoAppStore(urlString: urlString)
        default:
            result(FlutterMethodNotImplemented)
        }
  }

       //跳转到应用的AppStore页页面
      func gotoAppStore(urlString: String) {
          if let url = URL(string: urlString) {
              //根据iOS系统版本，分别处理
              if #available(iOS 10, *) {
                  UIApplication.shared.open(url, options: [:],completionHandler: {(success) in })
              } else {
                  UIApplication.shared.openURL(url)
              }
          }
      }
}
