//
//  EntryViewController.swift
//  EntryViewController
//
//
import RealmSwift
import UIKit

class EntryViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var addRecipeName: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var addRecipeDescription: UITextField!
    @IBOutlet var addRecipePrepTime: UITextField!
    @IBOutlet var addRecipeCookTime: UITextField!
    @IBOutlet var addRecipeCategory: UITextField!
    @IBOutlet var addRecipeIngredients: UITextField!
    @IBOutlet var addRecipeSteps: UITextView!
    
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.text = "";
        addRecipeName.becomeFirstResponder()
        
        addRecipeName.delegate = self
        addRecipeName.placeholder = "Insert Recipe's Name"
        
        addRecipeDescription.delegate = self
        addRecipeDescription.placeholder = "Insert Description"
        
        addRecipePrepTime.delegate = self
        addRecipePrepTime.placeholder = "0"
        
        addRecipeCookTime.delegate = self
        addRecipeCookTime.placeholder = "0"
        
        addRecipeCategory.delegate = self
        addRecipeCategory.placeholder = "Insert Category"
        
        addRecipeIngredients.delegate = self
        addRecipeIngredients.placeholder = "Insert Ingredients"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func didTapSaveButton(){
        if let recipeTempName = addRecipeName.text, !recipeTempName.isEmpty{
            if let recipeTempDescription = addRecipeDescription.text, !recipeTempDescription.isEmpty{
                if let recipeTempPrepTime = addRecipePrepTime.text, !recipeTempDescription.isEmpty{
                    if let recipeTempCookTime = addRecipeCookTime.text, !recipeTempCookTime.isEmpty{
                        if let recipeTempCategory = addRecipeCategory.text, !recipeTempCategory.isEmpty{
                            if let recipeTempIngredients = addRecipeIngredients.text, !recipeTempIngredients.isEmpty{
                                if let recipeTempSteps = addRecipeSteps.text, !recipeTempSteps.isEmpty{
                                        realm.beginWrite()
                                        let newRecipe = Recipe()
                                        newRecipe.date = Date()
                                        newRecipe.recipeName = recipeTempName
                                        newRecipe.recipeDescription = recipeTempDescription
                                        newRecipe.recipeIngredients = recipeTempIngredients
                                        newRecipe.recipeCategory = recipeTempCategory
                                        newRecipe.recipeCookTime = recipeTempCookTime
                                        newRecipe.recipePrepTime = recipeTempPrepTime
                                        newRecipe.recipeSteps = recipeTempSteps
                                        realm.add(newRecipe)
                                        try! realm.commitWrite()
                                        completionHandler?()
                                        navigationController?.popToRootViewController(animated: true)
                                    
                                }
                                else{
                                    errorLabel.text = "Missing Steps"
                                }
                            }
                            else{
                                errorLabel.text = "Missing Ingredients"
                            }
                            
                        }
                        else{
                            errorLabel.text = "Missing Category"
                        }
                        
                    }
                    else{
                        errorLabel.text = "Missing Cook Time"
                    }
                }
                else{
                    errorLabel.text = "Missing Prep Time"
                }
                
            }
            else{
                errorLabel.text = "Missing Description"
            }
        }
        else{
            errorLabel.text = "Missing Name"
        }
    


    }
}
