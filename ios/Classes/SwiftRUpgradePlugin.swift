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
        case "upgradeFromUrl":
            print(call.arguments ?? "null")
            guard let url = (call.arguments as? Dictionary<String, Any>)?["url"] as? String else {
                result(FlutterError(code: "参数url不能为空", message: nil, details: nil))
                return
            }
            result(openUrl(url: url))
            break
        case "upgradeFromAppStore":
            print(call.arguments ?? "null")
            guard let appId = (call.arguments as? Dictionary<String, Any>)?["appId"] as? String else {
                result(FlutterError(code: "参数appId不能为空", message: nil, details: nil))
                return
            }
            upgradeFromAppStore(appId: appId,result: result)
            break;
        case "getVersionFromAppStore":
            print(call.arguments ?? "null")
            guard let appId = (call.arguments as? Dictionary<String, Any>)?["appId"] as? String else{
                result(FlutterError(code: "参数appId不能为空", message: nil, details: nil))
                return
            }
            getVersionFromAppStore(appId: appId,result: result)
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    func openUrl(url:String) ->Bool{
        if let url = URL(string: url) {
            //根据iOS系统版本，分别处理
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],completionHandler: {(success) in })
            } else {
                UIApplication.shared.openURL(url)
            }
            return true;
        }
        return false;
    }
    
    //跳转到应用的AppStore页页面
    func upgradeFromAppStore(appId: String, result: @escaping FlutterResult) {
        let dict = getInfoFromAppStore(appId: appId);
        if((dict) != nil){
            let res = dict!["results"] as! NSArray
            let xx = res[0] as! NSDictionary
            let urlString = xx["trackViewUrl"] as! String
            result(openUrl(url: urlString))
        }else{
            result(false)
        }
    }
    
    //获取应用信息
    func getInfoFromAppStore(appId:String) -> NSDictionary? {
        let appUrl = "https://itunes.apple.com/lookup?id=" + appId
        do{
            let jsonData = NSData(contentsOf: NSURL(string: appUrl)! as URL)
            let json = try JSONSerialization.jsonObject(with: jsonData! as Data, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
            return json;
        }catch{
            NSLog("获取appId:%@ 对应的appStore信息失败",appId)
        }
        return nil;
    }
    
    func getVersionFromAppStore(appId:String,result: @escaping FlutterResult){
        let dict = getInfoFromAppStore(appId: appId)
        if((dict) != nil){
            let res = dict!["results"] as! NSArray
            let xx = res[0] as! NSDictionary
            result(xx["version"]! as! String)
        }else{
            result(nil)
        }
    }
}
