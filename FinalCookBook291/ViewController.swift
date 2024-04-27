import UIKit
import RealmSwift

// Define your Realm model with a primary key
class Recipe: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var recipeName: String = ""
    @objc dynamic var isFavorite: Bool = false
    @objc dynamic var recipeDescription: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var recipePrepTime: String = ""
    @objc dynamic var recipeCookTime: String = ""
    @objc dynamic var recipeCategory: String = ""
    @objc dynamic var recipeIngredients: String = ""
    @objc dynamic var recipeSteps: String = ""
    @objc dynamic var owner: User?  // Link to the User who owns the recipe

    override static func primaryKey() -> String? {
        return "id"
    }
}



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var table: UITableView!
    private var realm: Realm?
    private var data = [Recipe]()
    var currentUser: User?  // Declare currentUser property

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeRealm()
        fetchCurrentUser()
        setupTableView()
    }

    private func fetchCurrentUser() {
        UserSession.shared.fetchCurrentUser()
        if let user = UserSession.shared.currentUser {
            currentUser = user
            print("Current user set: \(user.username)")
            refresh()
        } else {
            print("No current user found. Possibly redirect to login.")
        }
    }

    private func initializeRealm() {
        do {
            realm = try Realm()
            print("Realm is initialized.")
        } catch {
            print("Failed to initialize Realm: \(error)")
        }
    }

    private func setupTableView() {
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)  // Optional: Deselect the row for visual feedback

        // Assuming 'ViewViewController' is the storyboard ID for ViewViewController
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ViewViewController") as? ViewViewController else {
            print("ViewViewController could not be instantiated.")
            return
        }
        
        vc.currRecipe = data[indexPath.row]
        vc.deletionHandler = { [weak self] in
            self?.refresh()  // Refresh the list after a recipe is deleted
        }
        navigationController?.pushViewController(vc, animated: true)
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let recipe = data[indexPath.row]
            cell.textLabel?.text = recipe.recipeName
            cell.accessoryView = createFavoriteButton(isFavorite: recipe.isFavorite, tag: indexPath.row)
            return cell
        }

        private func createFavoriteButton(isFavorite: Bool, tag: Int) -> UIButton {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: isFavorite ? "heart.fill" : "heart"), for: .normal)
            button.tintColor = isFavorite ? .red : .gray
            button.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
            button.tag = tag
            button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            return button
        }

        @objc func toggleFavorite(sender: UIButton) {
            let recipeIndex = sender.tag
            guard recipeIndex < data.count else { return }
            let recipe = data[recipeIndex]
            try! realm?.write {
                recipe.isFavorite = !recipe.isFavorite
                realm?.add(recipe, update: .modified)
            }
            table.reloadRows(at: [IndexPath(row: recipeIndex, section: 0)], with: .none)
        }
    
    @IBAction func didTapAddButton() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "EntryViewController") as? EntryViewController else {
            print("EntryViewController could not be instantiated.")
            return
        }
        vc.currentUser = self.currentUser
        vc.completionHandler = { [weak self] in
            self?.refresh()
        }
        navigationController?.pushViewController(vc, animated: true)
    }




    func refresh() {
        guard let realm = realm, let user = currentUser else {
            print("Realm or currentUser is not properly initialized.")
            return
        }

        realm.refresh()  // Make sure you are seeing the latest data

        data = Array(realm.objects(Recipe.self).filter("owner == %@", user))
        if data.isEmpty {
            print("No recipes found for current user \(user.username).")
        } else {
            print("Loaded \(data.count) recipes for user \(user.username).")
        }
        table.reloadData()
    }



    // Add this function to handle refreshing data when a new recipe is added
    func handleRecipeAdded() {
        refresh()
    }
}
