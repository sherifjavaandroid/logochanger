import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let iconChannel = FlutterMethodChannel(name: "com.example.dynamic_logo_app/icon",
                                           binaryMessenger: controller.binaryMessenger)
    iconChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "updateAppIcon" {
        guard let args = call.arguments as? [String : Any] else {return}
        let iconPath = args["iconPath"] as! String
        self.updateAppIcon(iconPath: iconPath)
        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func updateAppIcon(iconPath: String) {
    // Note: Dynamically changing app icons on iOS requires specific setup and is subject to App Store review.
    // This is a placeholder for where you would implement the icon change logic.
    // You may need to use alternate icons, which must be declared in your Info.plist
    print("Updating app icon to: \(iconPath)")
  }
}