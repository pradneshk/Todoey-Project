//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Pradnesh Kore on 25/07/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryArray = [TodoCategory]()
    var selectedCategory: TodoCategory?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()

    }
    
    @IBAction func addbuttonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happenones the user clicks the add item button on UIAlert
            if let newTitle = textField.text {
                if(newTitle != ""){
                    let newCategory = TodoCategory(context: self.ctx)
                    newCategory.name = newTitle
                    self.categoryArray.append(newCategory)
                    self.tableView.reloadData()
                    self.saveData()
                }
            }
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    

}


//MARK: - TableViewDataSourceMethods
extension CategoryViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
}

//MARK: - TableView Delegate Methods
extension CategoryViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categoryArray[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    
}

//MARK: - Database load & save method
extension CategoryViewController{
    
    func saveData(){
        do{
            try ctx.save()
        }catch{
            print("Error saving data: \(error)")
        }
    }
    
    func loadData(with request: NSFetchRequest<TodoCategory> = TodoCategory.fetchRequest()){
        do{
            categoryArray = try ctx.fetch(request)
            tableView.reloadData()
        }catch{
            print("Error getting data: \(error)")
        }
    }
    
}

//MARK: - Prepare for segue
extension CategoryViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoItems" {
            let destinationVC = segue.destination as! TodoListViewController
            destinationVC.category = selectedCategory
        }
    }
}
