import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Realm (including migration setup)
        initializeRealm()
        return true
    }

    private func initializeRealm() {
        // Define the Realm configuration for migration
        let config = Realm.Configuration(
            schemaVersion: 2,  // Increase if necessary to force a migration
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        if newObject!["id"] == nil {
                            newObject!["id"] = UUID().uuidString
                        }
                    }
                }
            })

        // Set the modified configuration as the default Realm configuration
        Realm.Configuration.defaultConfiguration = config

        // Try initializing Realm with the new configuration
        do {
            _ = try Realm()
        } catch {
            print("Realm initialization failed: \(error)")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Handle the transition to the background
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Handle the transition back to the foreground
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks paused (or not yet started) while the application was inactive
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate
    }
}
