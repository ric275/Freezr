//
//  FridgeViewController.swift
//  Freezr
//
//  Created by Jack Taylor on 01/11/2016.
//  Copyright © 2016-2018 Jack Taylor. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

class FridgeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets.
    
    @IBOutlet weak var itemListTableView: UITableView!
    
    @IBOutlet weak var emptyMessage1: UILabel!
    
    @IBOutlet weak var emptyMessage2: UILabel!
    
    //Variables.
    
    var fridgeItems : [FridgeItem] = []
    
    let today = NSDate()
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemListTableView.dataSource = self
        itemListTableView.delegate = self
        
        //Large TEXT
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            //navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.purple]
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    //Custom colours.
    
    let myPurple:UIColor = UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0)
    
    let newPurple:UIColor = UIColor(red: 125/255.0, green: 80/255.0, blue: 230/255.0, alpha: 1.0)
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Retrieve the FridgeItems from CoreData.
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            fridgeItems = try context.fetch(FridgeItem.fetchRequest())
            itemListTableView.reloadData()
        } catch {}
        
        //Orientation setup.
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldSupportAllOrientation = true
    }
    
    //Specifies how many rows are in the table.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        if fridgeItems.count == 0 {
            return 1
        } else {
            return fridgeItems.count
        }
    }
    
    //Specifies what goes in the table cells.
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if fridgeItems.count == 0 {
            
            let emptyCell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            
            emptyCell.textLabel?.text = "You should probably go buy food."
            emptyCell.textLabel?.font = UIFont(name: "Gill Sans", size: 17)
            
            return emptyCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "FridgeItemCell", for: indexPath) as! FridgeItemCell
            
            let fridgeItem = fridgeItems[indexPath.row]
            cell.itemNameLabel?.text = fridgeItem.name
            cell.itemNameLabel.font = UIFont(name: "GillSans-bold", size: 24)
            cell.expiryDateLabel.font = UIFont(name: "Gill Sans", size: 21)
            cell.itemNameLabel?.textColor = newPurple
            cell.itemImage?.image = UIImage(data: fridgeItem.image! as Data)
            
            if (fridgeItem.expirydate?.isEmpty)! {
                cell.expiryDateLabel?.textColor = myPurple
                cell.expiryDateLabel?.text = "Expires: Unknown"
                
            } else {
                
                //Expiry text setup.
                
                // Convert the String to a NSDate.
                
                let dateString = fridgeItem.expirydate
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MMM/yyyy"
                //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                let dateFromString = dateFormatter.date(from: dateString!)
                let twoWeeks = dateFromString?.addingTimeInterval(-1209600)
                
                //Change expiry text and colour accordingly.
                
                if today.isGreaterThanDate(dateToCompare: dateFromString!) {
                    cell.itemNameLabel.textColor = .red
                    cell.expiryDateLabel.text = "Expired: \(fridgeItem.expirydate!)"
                    cell.expiryDateLabel.textColor = .red
                    
                } else if today.isGreaterThanDate(dateToCompare: twoWeeks!) {
                    
                    cell.expiryDateLabel.text = "Expires: \(fridgeItem.expirydate!)"
                    cell.expiryDateLabel.textColor = .orange
                    
                } else {
                    
                    cell.expiryDateLabel.text = "Expires: \(fridgeItem.expirydate!)"
                    cell.expiryDateLabel.textColor = newPurple
                }
                
            }
        
            return cell
            
        }
    }
    
    //What happens when a cell is tapped.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if fridgeItems.count == 0 {
            print("User tapped the empty cell message! Do nothing.")
            tableView.deselectRow(at: indexPath, animated: true)
            
        } else {
            
            let fridgeItem = fridgeItems[indexPath.row]
            performSegue(withIdentifier: "fridgeItemSegue", sender: fridgeItem)
        }
    }
    
    //Sets up the next ViewController (ItemViewController) and sends some item data over.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fridgeItemSegue" {
            
            let nextViewController = segue.destination as! FridgeItemViewController
            nextViewController.fridgeItem = sender as? FridgeItem
            
            if nextViewController.fridgeItem != nil {
                
                let backButton = UIBarButtonItem()
                backButton.title = "Done"
                navigationItem.backBarButtonItem = backButton
                
            } else {
                let backButton = UIBarButtonItem()
                backButton.title = "Cancel"
                navigationItem.backBarButtonItem = backButton
            }
            
            
            //Hide tab bar in item view.
            nextViewController.hidesBottomBarWhenPushed = true
            
        } else {
            
            let nextViewController = segue.destination as! InfoViewController
            nextViewController.navigationItem.title = "Settings"
            let backButton = UIBarButtonItem()
            backButton.title = "Done"
            nextViewController.navigationItem.backBarButtonItem = backButton
            
            //Hide tab bar in settings.
            nextViewController.hidesBottomBarWhenPushed = true
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Display/hide the table and empty message accordingly.
        
        if fridgeItems.count == 0 {
            itemListTableView.isHidden = true
            emptyMessage1.isHidden = false
            emptyMessage2.isHidden = false
            
        } else {
            
            emptyMessage1.isHidden = true
            emptyMessage2.isHidden = true
            itemListTableView.isHidden = false
        }
    }
    
    //Swipe actions (add to shopping list & delete).
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //Swipe to add items to shopping list.
        
        let swipeToAdd = UITableViewRowAction(style: .normal, title: "Shopping List") { (action:UITableViewRowAction!, NSIndexPath) in
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let SLItem = ShoppingListItem(context: context)
            SLItem.name = self.fridgeItems[indexPath.row].name
            SLItem.image = self.fridgeItems[indexPath.row].image!
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //SOUNDS
            
            //Create the alert sound
            
            let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "shoppingListSound", ofType: "mp3")!)
            
            //Set up sound playback
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            } catch {
                print("sound error1")
            }
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("sound error2")
            }
            
            //Play sound
            
            if UserDefaults.standard.bool(forKey: "soundSwitchOn") == false {
                
                do {
                    try self.audioPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
                } catch {
                    print("Playback error")
                }
                
                self.audioPlayer.volume = 0.07
                self.audioPlayer.prepareToPlay()
                self.audioPlayer.play()
                
            } else {
                print("sounds off")
            }
            
            //Add badge to SL icon
            
            for item in self.tabBarController!.tabBar.items! {
                if item.title == "Shopping List" {
                    item.badgeValue = "New!"
                }
            }
            
            //Create the alert when an item has been added to the shopping list.
            
            if (self.fridgeItems[indexPath.row].name?.isEmpty)! {
                let alertVC = UIAlertController(title: "Item added", message: "This item has been added to your Shopping List.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                
                alertVC.addAction(okAction)
                
                self.present(alertVC, animated: true, completion: nil)
                
            } else {
                
                let alertVC = UIAlertController(title: "Item added", message: "\(self.fridgeItems[indexPath.row].name!) added to your Shopping List.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                
                alertVC.addAction(okAction)
                
                self.present(alertVC, animated: true, completion: nil)
            }
        }
        
        swipeToAdd.backgroundColor = .purple
        
        //Swipe to delete items from the fridge.
        
        let swipeToDelete = UITableViewRowAction(style: .normal, title: "Delete") { (action:UITableViewRowAction!, NSIndexPath) in
            
            let fridgeItem = self.fridgeItems[indexPath.row]
            
            //Some setup for notifcation deletion.
            let identifier = fridgeItem.notifid
            let twoWeekIdentifier = fridgeItem.twoweeknotifid
            let oneWeekIdentifier = fridgeItem.oneweeknotifid
            let twoDayIdentifier = fridgeItem.twodaynotifid
            
            //This is here to catch the 1.3.2 transition.
            
            if fridgeItem.notifid != nil {
                print("delete:: \(identifier!)")
            }
            if fridgeItem.twoweeknotifid != nil {
                print("two week delete:: \(twoWeekIdentifier!)")
            }
            if fridgeItem.oneweeknotifid != nil {
                print("one week delete:: \(oneWeekIdentifier!)")
            }
            if fridgeItem.twodaynotifid != nil {
                print("two day delete:: \(twoDayIdentifier!)")
            }
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(fridgeItem)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //Delete pending notifications.
            UNUserNotificationCenter.current().getPendingNotificationRequests { (notificationRequests) in
                var identifiers: [String] = []
                for notification:UNNotificationRequest in notificationRequests {
                    
                    //This is here to catch the 1.3.2 transition.
                    if identifier != nil {
                        
                        if notification.identifier == "\(identifier!)" {
                            identifiers.append(notification.identifier)
                            
                        } else if notification.identifier == "\(twoWeekIdentifier!)" {
                            identifiers.append(notification.identifier)
                            
                        } else if notification.identifier == "\(oneWeekIdentifier!)" {
                            identifiers.append(notification.identifier)
                            
                        } else if notification.identifier == "\(twoDayIdentifier!)" {
                            identifiers.append(notification.identifier)
                            
                        }
                    }
                }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            }
            
            do {
                self.fridgeItems = try context.fetch(FridgeItem.fetchRequest())
                tableView.reloadData()
            } catch {}
        }
        
        swipeToDelete.backgroundColor = UIColor.red
        
        return[swipeToDelete, swipeToAdd]
    }
    
    //Final declaration:
    
}
