//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var itemResults : Results<Item>?
    let defaults = UserDefaults.standard
    var parentCategoryPredicate : NSPredicate?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            //parentCategoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
            readData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        //readData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let category = selectedCategory {
            let navBar = navigationController?.navigationBar
            let categoryColor = UIColor.init(hexString: category.color)
            navBar?.backgroundColor = categoryColor
            title = category.name
            searchBar.barTintColor = categoryColor
            let contrastingColor = ContrastColorOf(categoryColor ?? UIColor.black, returnFlat: true)
            navBar?.tintColor = contrastingColor
            
            navBar?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastingColor]
            
        }
        
    }
    
    //MARK: - Actions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        print("Add Clicked")
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once the user pressed add item
            print("Action Pressed")
            if let safeTextFields = alert.textFields {
                let safeTextField = safeTextFields[0]
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = safeTextField.text!
                            newItem.dateCreated = Date().timeIntervalSince1970
                            currentCategory.items.append(newItem)
                            self.realm.add(newItem)
                        }
                    } catch {
                        print(error)
                    }
                }
            }
            self.tableView.reloadData()
        }
        alert.addAction(action)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Do Some App Developing"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Table View delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemResults?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let todo = itemResults?[indexPath.row] {
            cell.textLabel?.text = todo.title
            cell.backgroundColor = UIColor(hexString: self.selectedCategory?.color ?? "")?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemResults!.count) )
            if let backgroundColor = cell.backgroundColor {
                cell.textLabel?.textColor = ContrastColorOf(backgroundColor, returnFlat: true)
            }
            
            cell.accessoryType = todo.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "There are no results in cateogory"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemResults[indexPath.row])
        
        if let item = itemResults?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !(item.done)
                    //realm.delete(item)
                })
            } catch {
                print(error)
            }
            tableView.reloadData()
        }
        
        //Deletion from Arrays and Context
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        //saveData(from: itemResults[indexPath.row])
        //tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    func readData() {
        itemResults = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
    
    func deleteCell(item: Item) {
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Error deleting item: \(error)")
        }
    }
    
    override func updateModel(at: IndexPath) {
        if let itemToDelete = itemResults?[at.row] {
            deleteCell(item: itemToDelete)
        }
    }
}

//MARK: - Search Bar delegate methords
extension TodoListViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        itemResults = itemResults?.filter(predicate).sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            readData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

