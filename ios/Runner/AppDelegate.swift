import Flutter
import UIKit
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Add debug information
    let bundleID = Bundle.main.bundleIdentifier
    print("Current Bundle ID: \(bundleID ?? "unknown")")

    if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
      print("Found GoogleService-Info.plist at path: \(filePath)")
      FirebaseApp.configure()
      print("Firebase configured successfully")
    } else {
      // Try to list all files in the bundle to debug
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
}