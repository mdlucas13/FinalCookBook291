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
            // Directly format the date as it's non-optional
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
        realm.beginWrite()
        realm.delete(recipe)
        try! realm.commitWrite()
        deletionHandler?()
        navigationController?.popViewController(animated: true)
    }
}
