import AVFoundation
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    private let appAudioSession = AppAudioSession(
        audioSession: .sharedInstance()
    )

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        appAudioSession.configure()
        return true
    }
}
