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
    //MARK: - Add New Category
    @IBAction func addbuttonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            //what will happenones the user clicks the add item button on UIAlert
            if let newTitle = textField.text {
                if(newTitle != ""){
                    let newCategory = TodoCategory(context: self.ctx)
                    newCategory.name = newTitle
                    self.categoryArray.append(newCategory)
                    self.saveData()
                }
            }
        }
        
        let dismissAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            alert.resignFirstResponder()
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(action)
        alert.addAction(dismissAction)
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
        tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<TodoCategory> = TodoCategory.fetchRequest()){
        do{
            categoryArray = try ctx.fetch(request)
            tableView.reloadData()
        }catch{
            print("Error getting data: \(error)")
        }
        tableView.reloadData()
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

//MARK: - Search Bar Delegate
extension CategoryViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            search(for: text)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText==""){
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        search(for: searchText)
    }
    
    func search(for text: String){
        if(text == ""){
            loadData()
        }else{
            let request: NSFetchRequest<TodoCategory> = TodoCategory.fetchRequest()
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            loadData(with: request)
        }
    }
}
