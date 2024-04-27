import Foundation
import RealmSwift

class UserSession {
    static let shared = UserSession()
    private var _currentUser: User?

    var currentUser: User? {
        get {
            if _currentUser == nil {
                fetchCurrentUser()
            }
            return _currentUser
        }
        set {
            _currentUser = newValue
            if let userID = newValue?.id {
                UserDefaults.standard.set(userID, forKey: "lastLoggedInUserId")
                UserDefaults.standard.synchronize() // Ensure data is saved immediately.
            }
        }
    }

    func fetchCurrentUser() {
        guard let userId = UserDefaults.standard.string(forKey: "lastLoggedInUserId"),
              let realm = try? Realm() else {
            print("No userID found in UserDefaults.")
            return
        }
        _currentUser = realm.object(ofType: User.self, forPrimaryKey: userId)
        if _currentUser == nil {
            print("No user found in Realm for the stored userID.")
        }
    }
}
