import Flutter
import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let bundleID = Bundle.main.bundleIdentifier
    print("Current Bundle ID: \(bundleID ?? "unknown")")

    if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
      print("Found GoogleService-Info.plist at path: \(filePath)")
      FirebaseApp.configure()
      print("Firebase configured successfully")

      Messaging.messaging().delegate = self

      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
      } else {
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }

      application.registerForRemoteNotifications()

    } else {
      if let resourcePath = Bundle.main.resourcePath {
        print("Searching for plist files in bundle...")
        do {
          let fileManager = FileManager.default
          let items = try fileManager.contentsOfDirectory(atPath: resourcePath)
          for item in items where item.hasSuffix(".plist") {
            print("Found plist file: \(item)")
          }
        } catch {
          print("Failed to list directory: \(error)")
        }
      }
      print("Error: GoogleService-Info.plist not found in bundle")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("APNs token retrieved: \(deviceToken)")
    Messaging.messaging().apnsToken = deviceToken
  }

  override func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Unable to register for remote notifications: \(error.localizedDescription)")
  }

  override func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    print("Received remote notification in foreground: \(userInfo)")
  }

  override func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print("Received remote notification with completion: \(userInfo)")

    if let messageID = userInfo["gcm.message_id"] {
      print("Message ID: \(messageID)")
    }

    completionHandler(.newData)
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let bundleID = Bundle.main.bundleIdentifier
    print("Current Bundle ID: \(bundleID ?? "unknown")")

    if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
      print("Found GoogleService-Info.plist at path: \(filePath)")
      FirebaseApp.configure()
      print("Firebase configured successfully")

      Messaging.messaging().delegate = self

      // यहाँ से notification configuration शुरू होती है
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self

        // यहाँ मैंने criticalAlert add करने का सुझाव दिया था
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .criticalAlert]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { granted, error in
            print("Notification permission granted: \(granted)")
            if let error = error {
              print("Notification permission error: \(error)")
            }
          }
        )
      } else {
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }

      application.registerForRemoteNotifications()

    } else {
      // Your existing plist search code...
      print("Error: GoogleService-Info.plist not found in bundle")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

@available(iOS 10, *)
extension AppDelegate {
  // UNUserNotificationCenterDelegate मेथड्स
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    print("Notification received in foreground: \(userInfo)")

    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .list, .sound, .badge]])
    } else {
      completionHandler([[.alert, .sound, .badge]])
    }
  }

  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    print("User tapped on notification: \(userInfo)")

    completionHandler()
  }
}

extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    let deviceToken = fcmToken ?? "unknown"
    print("Firebase registration token: \(deviceToken)")

    let dataDict: [String: String] = ["token": deviceToken]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}