//
//  FreezrViewController.swift
//  Freezr
//
//  Created by Jack Taylor on 09/10/2016.
//  Copyright © 2016-2018 Jack Taylor. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

class FreezrViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Outlets.
    
    @IBOutlet weak var itemListTableView: UITableView!
    
    @IBOutlet weak var emptyMessage1: UILabel!
    
    @IBOutlet weak var emptyMessage2: UILabel!
    
    //Variables.
    
    var items : [Item] = []
    
    let today = NSDate()
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyMessage1.textColor = newPurple2
        emptyMessage2.textColor = newPurple2
        
        itemListTableView.dataSource = self
        itemListTableView.delegate = self
        
        //Large TEXT!!
        
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
    
    let newPurple2:UIColor = UIColor(red: 146/255.0, green: 54/255.0, blue: 240/255.0, alpha: 1.0)

    
    override func viewWillAppear(_ animated: Bool) {
        
        //Retrieve the FridgeItems from CoreData.
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            items = try context.fetch(Item.fetchRequest())
            itemListTableView.reloadData()
        } catch {}
        
        //Orientation setup.
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldSupportAllOrientation = true
    }
    
    //Specifies how many rows are in the table.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        if items.count == 0 {
            return 1
        } else {
            return items.count
        }
    }
    
    //Specifies what goes in the table cells.
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if items.count == 0 {
            
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            
            cell.textLabel?.text = "You should probably go buy food."
            cell.textLabel?.font = UIFont(name: "Gill Sans", size: 17)
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
            
            let item = items[indexPath.row]
            cell.itemNameLabel.text = item.name
            cell.itemNameLabel.font = UIFont(name: "GillSans-bold", size: 24)
            cell.expiryDateLabel.font = UIFont(name: "Gill Sans", size: 21)
            cell.itemNameLabel.textColor = myPurple
            cell.itemImage.image = UIImage(data: item.image! as Data)
            
            if (item.expirydate?.isEmpty)! {
                cell.expiryDateLabel.textColor = myPurple
                cell.expiryDateLabel.text = "Expires: Unknown"
                
            } else {
                
                //Expiry text setup.
                
                // Convert the String to a NSDate.
                
                let dateString = item.expirydate
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MMM/yyyy"
                //dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
                let dateFromString = dateFormatter.date(from: dateString!)
                let twoWeeks = dateFromString?.addingTimeInterval(-1209600)
                
                //Change expiry text and colour accordingly.
                
                if today.isGreaterThanDate(dateToCompare: dateFromString!) {
                    cell.itemNameLabel.textColor = .red
                    cell.expiryDateLabel.text = "Expired: \(item.expirydate!)"
                    cell.expiryDateLabel.textColor = .red
                    
                } else if today.isGreaterThanDate(dateToCompare: twoWeeks!) {
                    
                    cell.expiryDateLabel.text = "Expires: \(item.expirydate!)"
                    cell.expiryDateLabel.textColor = .orange
                    
                } else {
                    
                    cell.expiryDateLabel.text = "Expires: \(item.expirydate!)"
                    cell.expiryDateLabel.textColor = newPurple
                }
            }
            
            return cell
            
        }
        
    }
    
    
    //What happens when a cell is tapped.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if items.count == 0 {
            print("User tapped the empty cell message! Do nothing.")
            tableView.deselectRow(at: indexPath, animated: true)
            
        } else {
            
            let item = items[indexPath.row]
            performSegue(withIdentifier: "itemSegue", sender: item)
        }
    }
    
    //Sets up the next ViewController (ItemViewController) and sends some item data over.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "itemSegue" {
            
            let nextViewController = segue.destination as! ItemViewController
            nextViewController.item = sender as? Item
            
            if nextViewController.item != nil {
                
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
        
        if items.count == 0 {
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
        
        //Swipe to add items to shopping list
        
        let swipeToAdd = UITableViewRowAction(style: .normal, title: "Shopping List") { (action:UITableViewRowAction!, NSIndexPath) in
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let SLItem = ShoppingListItem(context: context)
            SLItem.name = self.items[indexPath.row].name
            SLItem.image = self.items[indexPath.row].image!
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            //SOUNDS
            
            //Create the alert sound
            
            let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "shoppingListSound", ofType: "mp3")!)
            
            //Set up sound playback
            
            do {
                try AVAudioSession.sharedInstance().setCategoryconvertFromAVAudioSessionCategory(AVAudioSession.Category.ambient)
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
            
            if (self.items[indexPath.row].name?.isEmpty)! {
                let alertVC = UIAlertController(title: "Item added", message: "This item has been added to your Shopping List.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                
                alertVC.addAction(okAction)
                
                self.present(alertVC, animated: true, completion: nil)
                
            } else {
                
                let alertVC = UIAlertController(title: "Item added", message: "\(self.items[indexPath.row].name!) added to your Shopping List.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                
                alertVC.addAction(okAction)
                
                self.present(alertVC, animated: true, completion: nil)
            }
        }
        
        swipeToAdd.backgroundColor = newPurple2
        
        //Swipe to delete items from the freezer.
        
        let swipeToDelete = UITableViewRowAction(style: .normal, title: "Delete") { (action:UITableViewRowAction!, NSIndexPath) in
            
            if self.items.count == 0 {
                tableView.reloadData()
            } else {
                
                let item = self.items[indexPath.row]
                
                //Some setup for notifcation deletion.
                let identifier = item.notifid
                let twoWeekIdentifier = item.twoweeknotifid
                let oneWeekIdentifier = item.oneweeknotifid
                let twoDayIdentifier = item.twodaynotifid
                
                //This is here to catch the 1.3.2 transition.
                
                if item.notifid != nil {
                    print("delete:: \(identifier!)")
                }
                if item.twoweeknotifid != nil {
                    print("two week delete:: \(twoWeekIdentifier!)")
                }
                if item.oneweeknotifid != nil {
                    print("one week delete:: \(oneWeekIdentifier!)")
                }
                if item.twodaynotifid != nil {
                    print("two day delete:: \(twoDayIdentifier!)")
                }
                
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                context.delete(item)
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
                    self.items = try context.fetch(Item.fetchRequest())
                    tableView.reloadData()
                } catch {}
            }
        }
        
        swipeToDelete.backgroundColor = UIColor.red
        
        if items.count == 0 {
            return nil
        } else {
            return[swipeToDelete, swipeToAdd]
        }
    }
    
    //Final declaration:
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
