import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import AppTrackingTransparency

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    UIApplication.shared.applicationIconBadgeNumber = 0

    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
      override func applicationDidBecomeActive(_ application: UIApplication) { // add this function
//          if #available(iOS 14, *) {
//            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
//                switch status {
//                case .authorized:
//                    // Tracking authorization dialog was shown
//                    // and we are authorized
//                    print("Authorized")
//                case .denied:
//                    // Tracking authorization dialog was
//                    // shown and permission is denied
//                    print("Denied")
//                case .notDetermined:
//                    // Tracking authorization dialog has not been shown
//                    print("Not Determined")
//                case .restricted:
//                    print("Restricted")
//                @unknown default:
//                    print("Unknown")
//                }
//            })
//          } else {
//              //you got permission to track, iOS 14 is not yet installed
//          }
        }

    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            // Pass device token to auth
            Auth.auth().setAPNSToken(deviceToken, type: .unknown)

            // Pass device token to messaging
            //Messaging.messaging().apnsToken = deviceToken

            return super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }

    override func application(_ application: UIApplication,
                              didReceiveRemoteNotification notification: [AnyHashable : Any],
                              fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle the message for firebase auth phone verification
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }

        // Handle it for firebase messaging analytics
        if ((notification["gcm.message_id"]) != nil) {
            //Messaging.messaging().appDidReceiveMessage(notification)
        }

        return super.application(application, didReceiveRemoteNotification: notification, fetchCompletionHandler: completionHandler)
    }

    // https://firebase.google.com/docs/auth/ios/phone-auth#appendix:-using-phone-sign-in-without-swizzling
    override func application(_ application: UIApplication, open url: URL,
                              options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        // Handle auth reCAPTCHA when silent push notifications aren't available
        if Auth.auth().canHandle(url) {
            return true
        }

        return super.application(application, open: url, options: options)
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        print("APP_ENTER_IN_FOREGROUND")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
