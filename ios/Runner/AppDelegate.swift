import Flutter
import UIKit
import NaverThirdPartyLogin

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      NaverThirdPartyLoginConnection.getSharedInstance()?.isNaverAppOauthEnable = true
      NaverThirdPartyLoginConnection.getSharedInstance()?.isInAppOauthEnable = true
      
      let thirdConn = NaverThirdPartyLoginConnection.getSharedInstance()
      thirdConn?.serviceUrlScheme = "my_new_app"
      thirdConn?.consumerKey = "BwOlcNK5CVWTaGz04LhL"
      thirdConn?.consumerSecret = "N43CWtMh_T"
      thirdConn?.appName = "datingapp"


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    var applicationResult = false
    if (!applicationResult) {
       applicationResult = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
    }
    // if you use other application url process, please add code here.
    
    if (!applicationResult) {
       applicationResult = super.application(app, open: url, options: options)
    }
    return applicationResult
}
}
