import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Ключ Google Maps приходит из Info.plist (GMSApiKey), куда подставляется
    // $(GOOGLE_MAPS_API_KEY) из ios/Flutter/GoogleMaps.xcconfig. Плагин
    // google_maps_flutter на iOS читает ключ только отсюда — без вызова
    // provideAPIKey карта остаётся пустой.
    if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
      !key.isEmpty
    {
      GMSServices.provideAPIKey(key)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
