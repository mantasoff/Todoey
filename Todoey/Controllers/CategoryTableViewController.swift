//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Mantas Paškevičius on 2020-04-25.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    var categoryArray : Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = UIColor.flatMint()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var categoryTextField = UITextField()
        let alert = UIAlertController(title: "Add a new category", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if let categoryName = categoryTextField.text {
                let newCategory = Category()
                newCategory.name = categoryName
                newCategory.color = UIColor.randomFlat().hexValue()
                self.save(from: newCategory)
                self.tableView.reloadData()
            }
        }
        alert.addAction(alertAction)
        
        alert.addTextField { (textField) in
            categoryTextField = textField
        }
        
        present(alert, animated: true)
    }
    
    //MARK: - TableView Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categoryArray?[indexPath.row] {
            cell.backgroundColor = UIColor(hexString: category.color)
            cell.textLabel?.text = category.name
            if let backgroundColor = cell.backgroundColor {
                cell.textLabel?.textColor = ContrastColorOf(backgroundColor, returnFlat: true)
            }
        } else {
            cell.backgroundColor = UIColor.randomFlat()
            cell.textLabel?.text = "No Categories added yet"
        }
        
        return cell
    }
    //MARK: - Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation
    func readData() {
        categoryArray = realm.objects(Category.self)
    }
    
    func save(from category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print(error)
        }
        
        
    }
    
    func deleteCategory(_ deletionCategory: Category) {
        do {
            try realm.write {
                for item in deletionCategory.items {
                    print("Deleting Items")
                    realm.delete(item)
                    
                }
                print("Deleting Categories")
                realm.delete(deletionCategory)
            }
        } catch {
            print("Error While Deleting Category: \(error)")
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryToDelete = categoryArray?[indexPath.row] {
            deleteCategory(categoryToDelete)
        }
        
    }
}
