import UIKit
import RealmSwift
import CryptoKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var realm: Realm?

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeRealm()
    }
    
    private func initializeRealm() {
        do {
            realm = try Realm()
            print("Realm is initialized.")
        } catch {
            print("Realm initialization failed: \(error)")
            showAlert("Database Error", "Failed to initialize the database.")
        }
    }

    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
    
    guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("Input Error", "Username and password cannot be empty.")
            return
        }

        let hashedPassword = sha256(password)
        if let user = loadUser(username: username, password: hashedPassword) {
            print("User found: \(user.username)")
            UserSession.shared.currentUser = user
            navigateToMainViewController(currentUser: user)
        } else {
            print("No user found, creating new.")
            let newUser = User()
            newUser.username = username
            newUser.password = hashedPassword
            saveUser(user: newUser)
        }
    }


    private func loadUser(username: String, password: String) -> User? {
        return realm?.objects(User.self).filter("username = %@ AND password = %@", username, password).first
    }
    
    private func createAndSaveUser(username: String, hashedPassword: String) {
        let newUser = User()
        newUser.username = username
        newUser.password = hashedPassword
        saveUser(user: newUser)
    }
    
    private func saveUser(user: User) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.add(user, update: .modified)
                print("User saved: \(user.username)")
                UserSession.shared.currentUser = user
                navigateToMainViewController(currentUser: user)
            }
        } catch {
            print("Failed to save user: \(error)")
            showAlert("Database Error", "Failed to save user data.")
        }
    }

    
    private func setUserAndNavigate(_ user: User) {
        UserSession.shared.currentUser = user  // Setting the current user
        navigateToMainViewController(currentUser: user)
    }
    
    private func navigateToMainViewController(currentUser: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            mainVC.currentUser = currentUser
            DispatchQueue.main.async { [weak self] in
                self?.navigationController?.setViewControllers([mainVC], animated: true)
                print("Transition to main view with user: \(currentUser.username)")
            }
        } else {
            print("Failed to instantiate ViewController with identifier 'ViewController'.")
        }
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
