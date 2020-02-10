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

class ToDoListViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    var resultItems: Results<Item>?
    var realm = try! Realm()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    let defaults = UserDefaults.standard  //used to persist "small" data even if app terminates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.separatorStyle = .none
        
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colorHex = selectedCategory?.cellColor {
            title = selectedCategory?.name
            
            guard let navBar = navigationController?.navigationBar else{fatalError("navbar does not exist")}
            
            if let navBarColor = UIColor(hexString: colorHex) {
                navBar.backgroundColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                searchBar.barTintColor = navBarColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor :
                    ContrastColorOf(navBarColor, returnFlat: true)
                ]
            }
        }
        
    }
    
    //MARK: - TableView Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultItems?.count ?? 1  //3 cells initially
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let message = resultItems[indexPath.row]
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = resultItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            //===============***********================
            // for gradient color look
            if let color = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage: (CGFloat((indexPath.row))/CGFloat(resultItems!.count))) {
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true) //for test color
                
              //==============**********================
            }
            
        } else {
            cell.textLabel?.text = "No items Added."
        }
        
        return cell
    }
    
    //MARK: - Table View Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(resultItems?[indexPath.row] as Any)
  
        //deleting items from context:
//        context.delete(resultItems[indexPath.row])
//        resultItems.remove(at: indexPath.row)
        
        if let item = resultItems?[indexPath.row] {
            do {
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status.")
            }
        }
        
        tableView.reloadData()  //for the tick mark to get displayed
        //resultItems?[indexPath.row].done = !(resultItems[indexPath.row].done)
        
        //saveItems()
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        
        tableView.deselectRow(at: indexPath, animated: true)  //highlight fadeaway
    }

    //MARK: - add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            //What will happen when the add button is pressed in the navigation bar
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                       let newItem = Item()
                       newItem.title = textField.text!
                        newItem.dateCreated = Date()
                       currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving items, \(error)")
                }
            }
            
            //newItem.parentCategory = self.selectedCategory
            
            
            //self.saveItems()
            
//            self.defaults.set(self.resultItems, forKey: "ToDoListArray")
            
            self.tableView.reloadData()  //populates the tableview with new item
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Data manipulation methods
    
//    func saveItems() {   //encodes the input data and saves it to the .plist file at a location
//
//        do {
//            try context.save()
//        } catch {
//            print("Error saving context, \(error)")
//        }
//
//        self.tableView.reloadData()
//    }
    
//    func loadItems() {    //decodes the data from the .plist file and then returns to the viewController for display to the user
//        if let data = try? Data(contentsOf: dataFilePath!) {
//            let decoder = PropertyListDecoder()
//            do {
//                resultItems = try decoder.decode([Item].self, from: data)
//            } catch {
//                print("Error decoding items array, \(error)")
//            }
//        }
//    }
    
    func loadItems() {
        //let request : NSFetchRequest<Item> = Item.fetchRequest()
        resultItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates:   [categoryPredicate, additionalPredicate])
//        } else {
//            request.predicate = categoryPredicate
//        }
//
//
////        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
////        request.predicate = compoundPredicate
//
//        do{
//            resultItems = try context.fetch(request)
//        } catch{
//            print("Enter fetching data from context.\(error)")
//        }
        tableView.reloadData()
    }
    
    //MARK: - deletion methods
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)

        if let categoriesForDeletion = self.resultItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoriesForDeletion)
                }
            } catch {
                print("Error deleting items, \(error)")
            }
        }
    }
}

//MARK: - Search Bar Method

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        resultItems = resultItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        //For sorting the search results in ascending order
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0){
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    

}
