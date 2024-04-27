import UIKit
import RealmSwift

class EntryViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet var addRecipeName: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var addRecipeDescription: UITextField!
    @IBOutlet var addRecipePrepTime: UITextField!
    @IBOutlet var addRecipeCookTime: UITextField!
    @IBOutlet var addRecipeCategory: UITextField!
    @IBOutlet var addRecipeIngredients: UITextField!
    @IBOutlet var addRecipeSteps: UITextView!

    private var realm: Realm?
    public var completionHandler: (() -> Void)?
    public var currentUser: User?  // Passed from previous controller

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeRealm()
        
        if let user = UserSession.shared.currentUser {
            currentUser = user
            setupTextFieldDelegates()
            setupPlaceholders()
            setupSaveButton()
        } else {
            showAlertForLogin()
        }
    }

    private func setupSaveButton() {
        let saveButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton(_:)))
        navigationItem.rightBarButtonItem = saveButtonItem
    }

    private func initializeRealm() {
        do {
            realm = try Realm()
        } catch {
            print("Failed to initialize Realm: \(error)")
            errorLabel.text = "Database error occurred."
        }
    }

    private func setupTextFieldDelegates() {
        addRecipeName.delegate = self
        addRecipeDescription.delegate = self
        addRecipePrepTime.delegate = self
        addRecipeCookTime.delegate = self
        addRecipeCategory.delegate = self
        addRecipeIngredients.delegate = self
        addRecipeSteps.delegate = self
    }

    private func setupPlaceholders() {
        addRecipeName.placeholder = "Insert Recipe's Name"
        addRecipeDescription.placeholder = "Insert Description"
        addRecipePrepTime.placeholder = "Preparation Time"
        addRecipeCookTime.placeholder = "Cooking Time"
        addRecipeCategory.placeholder = "Category"
        addRecipeIngredients.placeholder = "Ingredients"
        errorLabel.text = ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc func didTapSaveButton(_ sender: Any) {
        guard let user = currentUser else {
            errorLabel.text = "No user is currently logged in."
            return
        }

        guard let recipeName = addRecipeName.text, !recipeName.isEmpty,
              let description = addRecipeDescription.text, !description.isEmpty,
              let prepTime = addRecipePrepTime.text, !prepTime.isEmpty,
              let cookTime = addRecipeCookTime.text, !cookTime.isEmpty,
              let category = addRecipeCategory.text, !category.isEmpty,
              let ingredients = addRecipeIngredients.text, !ingredients.isEmpty,
              let steps = addRecipeSteps.text, !steps.isEmpty,
              let realm = realm else {
            errorLabel.text = "Please fill in all fields."
            return
        }

        do {
            try realm.write {
                let newRecipe = Recipe()
                newRecipe.recipeName = recipeName
                newRecipe.recipeDescription = description
                newRecipe.recipePrepTime = prepTime
                newRecipe.recipeCookTime = cookTime
                newRecipe.recipeCategory = category
                newRecipe.recipeIngredients = ingredients
                newRecipe.recipeSteps = steps
                newRecipe.date = Date()
                newRecipe.owner = user  // Make sure 'user' is a Realm-managed object
                        realm.add(newRecipe, update: .all)
                    }
                    print("Recipe saved successfully.")
                    completionHandler?()
                    navigationController?.popViewController(animated: true)
                } catch {
                    print("Error saving recipe: \(error)")
                    errorLabel.text = "Failed to save recipe."
                }
    }


    private func showAlertForLogin() {
        let alert = UIAlertController(title: "Not Logged In", message: "Please log in to continue.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Log In", style: .default, handler: { _ in
            self.redirectToLogin()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true)
    }

    private func redirectToLogin() {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            navigationController?.setViewControllers([loginVC], animated: true)
        }
    }
}
