import UIKit
import RealmSwift

// Define your Realm model with a primary key
class Recipe: Object {
    @objc dynamic var id: String = UUID().uuidString  // Unique identifier for each recipe
    @objc dynamic var recipeName: String = ""
    @objc dynamic var isFavorite: Bool = false
    @objc dynamic var recipeDescription: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var recipePrepTime: String = ""
    @objc dynamic var recipeCookTime: String = ""
    @objc dynamic var recipeCategory: String = ""
    @objc dynamic var recipeIngredients: String = ""
    @objc dynamic var recipeSteps: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var table: UITableView!
    private var realm = try! Realm()
    private var data = [Recipe]()

    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        refresh()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
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
        try! realm.write {
            recipe.isFavorite = !recipe.isFavorite
            realm.add(recipe, update: .modified)
        }
        table.reloadRows(at: [IndexPath(row: recipeIndex, section: 0)], with: .none)
    }
    
    @IBAction func didTapAddButton(){
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "enter") as? EntryViewController else{
                return
            }
            vc.completionHandler = { [weak self] in
                self?.refresh()
            }
            vc.title = "New Recipe"
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showRecipeDetails", sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipeDetails", let indexPath = sender as? IndexPath, let viewVC = segue.destination as? ViewViewController {
            let recipe = data[indexPath.row]
            viewVC.currRecipe = recipe
            viewVC.deletionHandler = { [weak self] in
                self?.refresh()
            }
        }
    }


    func refresh() {
        DispatchQueue.main.async {
            self.data = Array(self.realm.objects(Recipe.self).sorted(byKeyPath: "recipeName", ascending: true))
            self.table.reloadData()
        }
    }

}
