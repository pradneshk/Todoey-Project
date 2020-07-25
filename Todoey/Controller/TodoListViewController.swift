//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [TodoItem]()
    let ctx = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var category: TodoCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if category == nil {
            dismiss(animated: true, completion: nil)
        }
        loadData()
        
    }
    
    
}

//MARK: - DataSourceMethods
extension TodoListViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
}

//MARK: - TableViewDelegateMethods
extension TodoListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
//        ctx.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        saveData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}

//MARK: - AddItems
extension TodoListViewController{
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
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
                    let newItem = TodoItem(context: self.ctx)
                    newItem.title = newTitle
                    self.itemArray.append(newItem)
                    self.category?.addToItems(newItem)
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

//MARK: - DataMethods
extension TodoListViewController{
    
    func saveData(){
        do{
            try ctx.save()
        }catch {
            print(error)
        }
        self.tableView.reloadData()
    }

    
    func loadData(with request: NSFetchRequest<TodoItem>){
        do{
            itemArray = try ctx.fetch(request)
            self.tableView.reloadData()
        }catch{
            print("Error fetching data: \(error)")
        }
    }
    func loadData(){
        itemArray.removeAll()
        for item in category?.items?.allObjects as! [TodoItem]{
            itemArray.append(item)
        }
        tableView.reloadData()
    }

}

//MARK: - UISearchbarDelegate
extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        if let searchText = searchBar.text {
            searchForText(searchText)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            searchForText(searchText)
            if(searchText.count == 0){
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            }
        }
    }
    
    
    func searchForText(_ text: String){
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        if(text != ""){
            let safeCat = category!
            request.predicate = NSPredicate(format: "parentCategory.name = %@ AND title CONTAINS[cd] %@", safeCat.name!,text)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            loadData(with: request)
        } else {
            loadData()
        }
    }
    
}

