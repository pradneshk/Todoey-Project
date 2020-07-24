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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    self.saveData()
                }
            }
        }
        
        alert.addAction(action)
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

    func loadData(){
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        do{
            itemArray = try ctx.fetch(request)
            tableView.reloadData()
        }catch{
            print("Error fetching data: \(error)")
        }
    }

}
