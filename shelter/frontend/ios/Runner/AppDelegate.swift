import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller = window.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "audio_session",
                                       binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "configureAudioSession" {
        do {
          let session = AVAudioSession.sharedInstance()
          try session.setCategory(.playback, mode: .default, options: [])
          try session.setActive(true)
          result(nil)
        } catch {
          result(FlutterError(code: "AUDIO_SESSION_ERROR",
                              message: "Failed to set audio session",
                              details: error.localizedDescription))
        }
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
