import UIKit
import RealmSwift

class ViewViewController: UIViewController {
    public var currRecipe: Recipe?
    public var deletionHandler: (() -> Void)?
    private let realm = try! Realm()

    @IBOutlet var recipeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var recipePrepTimeLabel: UILabel!
    @IBOutlet var recipeCookTimeLabel: UILabel!
    @IBOutlet var recipeCategoryLabel: UILabel!
    @IBOutlet var recipeIngredientsLabel: UILabel!
    @IBOutlet var recipeStepsLabel: UITextView!

    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let recipe = currRecipe {
            recipeLabel.text = recipe.recipeName
            descriptionLabel.text = recipe.recipeDescription
            // Directly format the date since it's non-optional
            dateLabel.text = Self.dateFormatter.string(from: recipe.date)
            recipePrepTimeLabel.text = recipe.recipePrepTime
            recipeCookTimeLabel.text = recipe.recipeCookTime
            recipeCategoryLabel.text = recipe.recipeCategory
            recipeIngredientsLabel.text = recipe.recipeIngredients
            recipeStepsLabel.text = recipe.recipeSteps
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
    }


    @objc private func didTapDelete() {
        guard let recipe = currRecipe else {
            return
        }

        do {
            try realm.write {
                realm.delete(recipe)
            }
            deletionHandler?()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to delete the recipe: \(error)")
            showErrorAlert(message: "Failed to delete the recipe. Please try again.")
        }

        // Nullify the currRecipe if needed, though typically you just navigate away.
        currRecipe = nil
    }
   

    func clearUI() {
        recipeLabel.text = "Deleted"
        descriptionLabel.text = ""
        dateLabel.text = ""
        recipePrepTimeLabel.text = ""
        recipeCookTimeLabel.text = ""
        recipeCategoryLabel.text = ""
        recipeIngredientsLabel.text = ""
        recipeStepsLabel.text = ""
    }


    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}

