//
//  ShoppingListViewController.swift
//  Freezr
//
//  Created by Jack Taylor on 14/10/2016.
//  Copyright © 2016-2018 Jack Taylor. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets.
    
    @IBOutlet weak var shoppingListTableView: UITableView!
    
    @IBOutlet weak var emptyMessage1: UILabel!
    
    @IBOutlet weak var emptyMessage2: UILabel!
    
    @IBOutlet weak var emptyMessage3: UILabel!
    
    //Variables.
    
    var SLItems : [ShoppingListItem] = []
    
    //Custom colours.
    
    let myPurple:UIColor = UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0)
    
    let newPurple:UIColor = UIColor(red: 125/255.0, green: 80/255.0, blue: 230/255.0, alpha: 1.0)
    
    let newPurple2:UIColor = UIColor(red: 146/255.0, green: 54/255.0, blue: 240/255.0, alpha: 1.0)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyMessage1.textColor = newPurple2
        emptyMessage2.textColor = newPurple2
        emptyMessage3.textColor = newPurple2
        
        shoppingListTableView.dataSource = self
        shoppingListTableView.delegate = self
        
        //Large TEXT!!
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            //navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.purple]
        } else {
            // Fallback on earlier versions
        }
        
        // Do any additional setup after loading the view.
    }
    
    //Retrieve the ShoppingListItems from CoreData.
    
    override func viewWillAppear(_ animated: Bool) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            SLItems = try context.fetch(ShoppingListItem.fetchRequest())
            shoppingListTableView.reloadData()
        } catch {}
    }
    
    //Specifies how many rows are in the table.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        
        if SLItems.count == 0 {
            return 1
        } else {
            return SLItems.count
        }
    }
    
    //Specifies what goes in the table cells.
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if SLItems.count == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            
            cell.textLabel?.text = "Guess you bought everything ✔"
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SLItemCell", for: indexPath) as! SLItemCell
            
            cell.itemName?.textColor = newPurple
            cell.itemName?.font = UIFont(name: "Gill Sans", size: 20)
            
            let SLItem = SLItems[indexPath.row]
            cell.itemName?.text = SLItem.name
            cell.itemImage?.image = UIImage(data: SLItem.image! as Data)
            
            if SLItem.isChecked {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
        
        
    }
    
    //What happens when a cell is tapped - tick/untick the items.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)!
        
        let SLItem = SLItems[indexPath.row]
        
        if SLItems.count == 0 {
            
            print("User selected empty SL message, do not tick!")
            
        } else {
            
            if (cell.isSelected) {
                cell.isSelected = false
                
                if (cell.accessoryType == .none) {
                    cell.accessoryType = .checkmark
                    SLItem.isChecked = true
                    
                } else {
                    
                    cell.accessoryType = .none
                    SLItem.isChecked = false
                }
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    //Display/hide the table and empty message accordingly.
    
    override func viewDidAppear(_ animated: Bool) {
        
        if SLItems.count == 0 {
            shoppingListTableView.isHidden = true
            emptyMessage1.isHidden = false
            emptyMessage2.isHidden = false
            emptyMessage3.isHidden = false
        } else {
            emptyMessage1.isHidden = true
            emptyMessage2.isHidden = true
            emptyMessage3.isHidden = true
            shoppingListTableView.isHidden = false
        }
        
        //Remove badge from SL icon when the view loads.
        
        for item in self.tabBarController!.tabBar.items! {
            if item.title == "Shopping List" {
                item.badgeValue = nil
            }
        }
    }
    
    //Swipe to delete setup.
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = SLItems[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                SLItems = try context.fetch(ShoppingListItem.fetchRequest())
                shoppingListTableView.reloadData()
            } catch {}
        }
    }
    
    //Delete items from core data setup.
    
    func deleteShoppingListItems() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ShoppingListItem")
        request.includesPropertyValues = false
        
        do {
            let ShoppingListItems = try context.fetch(request) as! [NSManagedObject]
            
            if ShoppingListItems.count > 0 {
                
                for result: AnyObject in ShoppingListItems {
                    context.delete(result as! NSManagedObject)
                    print("ShoppingListItems have been deleted.")
                }
                try context.save() } } catch {}
    }
    
    //What happens when trash is tapped - clear the shopping list.
    
    @IBAction func trashTapped(_ sender: AnyObject) {
        
        let alertVC = UIAlertController(title: "Clear Shopping List?", message: "This will permanently delete all of the items from your Shopping List.", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let confirm = UIAlertAction(title: "Clear Shopping List", style: .destructive, handler: { (action) in
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            self.deleteShoppingListItems()
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                self.SLItems = try context.fetch(ShoppingListItem.fetchRequest())
                self.shoppingListTableView.reloadData()
            } catch {}
        })
        
        alertVC.addAction(cancel)
        
        alertVC.addAction(confirm)
        
        let emptyAlertVC = UIAlertController(title: "No items to delete!", message: "Your Shopping List is empty.", preferredStyle: .alert)
        
        let dismiss = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        emptyAlertVC.addAction(dismiss)
        
        if SLItems.count > 0 {
            
            self.present(alertVC, animated: true, completion: nil)
            
        } else {
            
            self.present(emptyAlertVC, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "SLSettingsSegue" {
        
            let nextViewController = segue.destination as! InfoViewController
            nextViewController.navigationItem.title = "Settings"
            let backButton = UIBarButtonItem()
            backButton.title = "Done"
            nextViewController.navigationItem.backBarButtonItem = backButton

            //Hide tab bar in settings.
            nextViewController.hidesBottomBarWhenPushed = true
        
        } else {
            
            let nextViewController = segue.destination as! AddToSLViewController
            let backButton = UIBarButtonItem()
            backButton.title = "Cancel"
            nextViewController.navigationItem.backBarButtonItem = backButton
            
            //Hide tab bar in add item view.
            nextViewController.hidesBottomBarWhenPushed = true
        }
    }
    
    //Final declaration:
    
}
