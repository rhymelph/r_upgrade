import Flutter
import UIKit

public class SwiftRUpgradePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.rhyme/r_upgrade_method", binaryMessenger: registrar.messenger())
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
            gotoAppStore(urlString: urlString,result: result)
            break;
        case "getVersionFromAppStore":
            print(call.arguments ?? "null")
            guard let id = (call.arguments as? Dictionary<String, Any>)?["id"] as? String else{
                result(FlutterError(code: "参数id不能为空", message: nil, details: nil))
                return
            }
            getVersionFromAppStore(idString: id,result: result)
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
  }

       //跳转到应用的AppStore页页面
    func gotoAppStore(urlString: String, result: @escaping FlutterResult) {
          if let url = URL(string: urlString) {
              //根据iOS系统版本，分别处理
              if #available(iOS 10, *) {
                  UIApplication.shared.open(url, options: [:],completionHandler: {(success) in })
              } else {
                  UIApplication.shared.openURL(url)
              }
            result(nil)
          }
      }
    
    func getVersionFromAppStore(idString:String,result: @escaping FlutterResult){
        let appUrl = "https://itunes.apple.com/lookup?id=" + idString
        do{
            let jsonData = NSData(contentsOf: NSURL(string: appUrl)! as URL)
            let jsonString = NSString.init(data: jsonData! as Data, encoding: String.Encoding.utf8.rawValue)
            
            let json = try JSONSerialization.jsonObject(with: jsonData! as Data, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
            NSLog(jsonString! as String)
            
            let res = json["results"] as! NSArray
            
            let xx = res[0] as! NSDictionary
            
            result(xx["version"]! as! String)
            
        }catch{
            NSLog("JSON解析失败")
        }
        result("")
    }
}
