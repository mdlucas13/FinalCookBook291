import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Realm (including migration setup)
        initializeRealm()

        // Create a UIWindow instance and set the rootViewController
        window = UIWindow(frame: UIScreen.main.bounds)

        // Set the initial view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Replace "Main" with the actual name of your storyboard
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            let navigationController = UINavigationController(rootViewController: loginViewController)
            window?.rootViewController = navigationController
        } else {
            print("Could not instantiate LoginViewController from storyboard")
        }

        window?.makeKeyAndVisible()

        return true
    }

    private func initializeRealm() {
        let config = Realm.Configuration(
            // Increment the schema version if you've previously used Realm in this project with a lower schema version.
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 3 {
                    migration.enumerateObjects(ofType: Recipe.className()) { oldObject, newObject in
                        // Since the owner property is new, set it to nil for all existing recipes.
                        newObject!["owner"] = nil
                    }
                }
            },
            deleteRealmIfMigrationNeeded: false  // You can set it to true during development to avoid dealing with migrations
        )
        
        // Apply the new configuration
        Realm.Configuration.defaultConfiguration = config
        
        // Initialize Realm with the configuration
        do {
            _ = try Realm()
        } catch {
            print("Realm initialization failed: \(error)")
        }
    }


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate
    }
}
