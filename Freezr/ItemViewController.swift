//
//  ItemViewController.swift
//  Freezr
//
//  Created by Jack Taylor on 09/10/2016.
//  Copyright © 2016-2018 Jack Taylor. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

class ItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //Custom colours.
    
    let myPurple:UIColor = UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0)
    
    //Outlets.
    
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemName: UITextField!
    
    @IBOutlet weak var addItemOrUpdateButton: UIButton!
    
    @IBOutlet weak var deleteItemButton: UIButton!
    
    @IBOutlet weak var expirationDateTextField: UITextField!
    
    @IBOutlet weak var placeHolderText1: UILabel!
    
    @IBOutlet weak var placeHolderText2: UILabel!
    
    @IBOutlet weak var addToSLButton: UIButton!
    
    @IBOutlet weak var imageNoticeText: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var expiresLabel: UILabel!
    
    @IBOutlet var bck: UIView!
    
    @IBOutlet weak var dateAddedLabel: UILabel!
    
    //Variables.
    
    var imageSelector = UIImagePickerController()
    
    var item : Item? = nil
    
    let today = NSDate()
    
    var selectedDate : Date? = nil
    var twoWeeks : Date? = nil
    var oneWeek : Date? = nil
    var twoDays : Date? = nil
    
    var audioPlayer = AVAudioPlayer()
    
    var activeField: UITextField?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageSelector.delegate = self
        
        itemName.delegate = self
        
        itemName.returnKeyType = UIReturnKeyType.done
        
        itemName.textColor = myPurple
        
        expirationDateTextField.textColor = myPurple
        
        itemImage.isUserInteractionEnabled = true
        
        //Setup the item view depending on if an existing item is being selected, or a new item is being added.
        
        //If there is an existing item:
        
        
        if item != nil {
            
            itemImage.image = UIImage(data: item!.image! as Data)
            itemName.text = item!.name
            expirationDateTextField.text = item!.expirydate
            
            placeHolderText1.isHidden = true
            placeHolderText2.isHidden = true
            imageNoticeText.isHidden = true
            
            addItemOrUpdateButton.setTitle("Update item", for: .normal)
            
            //Date added label.
            
            if item?.addeddate != nil {
                
                let labelFormatter = DateFormatter()
                
                labelFormatter.dateFormat = "MMM d, yyyy"
                
                let dateString = labelFormatter.string(from: (item?.addeddate)!)
                
                dateAddedLabel.text = "Date added: \(dateString)"
            } else {
                dateAddedLabel.isHidden = true
            }
            
            //Expiry text setup.
            
            // Convert the String to a NSDate.
            
            let dateString = expirationDateTextField.text
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MMM/yyyy"
            let dateFromString = dateFormatter.date(from: dateString!)
            let twoWeeks = dateFromString?.addingTimeInterval(-1209600)
            
            //Change expiry text and colour accordingly.
            
            if (item?.expirydate?.isEmpty)! {
                
                print("No expiry date given - do nothing")
                
            } else {
                
                if today.isGreaterThanDate(dateToCompare: dateFromString!) {
                    expirationDateTextField.textColor = .red
                    expiresLabel.text = "Expired:"
                    expiresLabel.textColor = .red
                    
                } else if today.isGreaterThanDate(dateToCompare: twoWeeks!) {
                    expirationDateTextField.textColor = .orange
                    expiresLabel.text = "Expiring soon:"
                    expiresLabel.textColor = .orange
                    
                } else {}
                
            }
            
            
            //If there is not an existing item:
            
        } else {
            
            deleteItemButton.isHidden = true
            addToSLButton.isHidden = true
            //addItemOrUpdateButton.isEnabled = false
            dateAddedLabel.isHidden = true
        }
        
        
        //Dismiss the keyboard when tapped away (setup).
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ItemViewController.dismissKeyboard)))
        
        //Tap the image (setup).
        
        self.itemImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ItemViewController.imageTapped)))
    }
    
    //Select image methods.
    
    @IBAction func photosTapped(_ sender: AnyObject) {
        imageSelector.sourceType = .photoLibrary
        present(imageSelector, animated: true, completion: nil)
    }
    
    @IBAction func cameraTapped(_ sender: AnyObject) {
        imageSelector.sourceType = .camera
        present(imageSelector, animated: true, completion: nil)
    }
    
    //Method called when an image has been selected.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        itemImage.image = image
        
        imageSelector.dismiss(animated: true, completion: nil)
        
        placeHolderText1.isHidden = true
        placeHolderText2.isHidden = true
        imageNoticeText.isHidden = true
        
        addItemOrUpdateButton.isEnabled = true
        
    }
    
    //What happens when Add or Update is tapped.
    
    
    @IBAction func addToFreezerTapped(_ sender: Any) {
        
        //If updating an exisitng item.
        
        if item != nil {
            item!.name = itemName.text
            item!.image = UIImageJPEGRepresentation(itemImage.image!, 0.05)! as Data?
            item?.expirydate = expirationDateTextField.text
            
            //Okay this is confusing - what this does is, when hitting update, it will create a notifID ONLY if there isn't already one. This should ONLY ever happen after the 1.3.1 > 1.3.2 transition.
            
            if item?.notifid == nil {
                item?.notifid = "\(today)"
                item?.twoweeknotifid = "\(today)" + "2week"
                item?.oneweeknotifid = "\(today)" + "1week"
                item?.twodaynotifid = "\(today)" + "2day"
            }
            
            //If a *new* expiry date is selected, schedule a new notification with the same notifID to overwrite the old one.
            
            if selectedDate != nil {
                
                if UserDefaults.standard.bool(forKey: "freezerSwitchOn") == true {
                    self.updateScheduleNotification(at: self.selectedDate!)
                }
                
                if UserDefaults.standard.bool(forKey: "preFreq2WeekTicked") == true {
                    self.updatePre2WeekNotification(at: self.twoWeeks!)
                }
                
                if UserDefaults.standard.bool(forKey: "preFreq1WeekTicked") == true {
                    self.updatePre1WeekNotification(at: oneWeek!)
                }
                
                if UserDefaults.standard.bool(forKey: "preFreq2DayTicked") == true {
                    self.updatePre2DayNotification(at: twoDays!)
                }
            }
            
            //If creating a new item.
            
        } else {
            
            if (itemName.text?.isEmpty)! && (itemImage.image == nil) {
                showTextErrorAlert()
            } else {
                
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let item = Item(context: context)
                item.name = itemName.text
                
                let defaultImage = UIImage(named: "freezerTemp")
                
                if itemImage.image == nil {
                    item.image = UIImageJPEGRepresentation(defaultImage!, 0.05)! as Data?
                } else {
                    item.image = UIImageJPEGRepresentation(itemImage.image!, 0.05)! as Data? //was 0.1
                }
                
                item.addeddate = today as Date
                
                item.expirydate = expirationDateTextField.text
                item.notifid = "\(today)"
                item.twoweeknotifid = "\(today)" + "2week"
                item.oneweeknotifid = "\(today)" + "1week"
                item.twodaynotifid = "\(today)" + "2day"
                
                print("NOTIFID::\(item.notifid!)")
                print("2 WEEK NOTIFID::\(item.twoweeknotifid!)")
                print("1 WEEK NOTIFID::\(item.oneweeknotifid!)")
                print("2 DAY NOTIFID::\(item.twodaynotifid!)")
                
                //(UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                //If an expiry date is selected, schedule a notification with the current date as the identifier.
                
                if selectedDate != nil {
                    
                    if UserDefaults.standard.bool(forKey: "freezerSwitchOn") == true {
                        self.scheduleNotification(at: self.selectedDate!)
                    }
                    
                    if UserDefaults.standard.bool(forKey: "preFreq2WeekTicked") == true {
                        self.pre2WeekNotification(at: self.twoWeeks!)
                    }
                    
                    if UserDefaults.standard.bool(forKey: "preFreq1WeekTicked") == true {
                        self.pre1WeekNotification(at: oneWeek!)
                    }
                    
                    if UserDefaults.standard.bool(forKey: "preFreq2DayTicked") == true {
                        self.pre2DayNotification(at: twoDays!)
                    }
                }
            }
            
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        //SOUNDS
        
        //Create the alert sound
        
        let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "addSound", ofType: "mp3")!)
        
        let alertSound2 = NSURL(fileURLWithPath: Bundle.main.path(forResource: "deleteSound", ofType: "mp3")!)
        
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
            
            if (itemName.text?.isEmpty)! && (itemImage.image == nil) {
                
                do {
                    try audioPlayer = AVAudioPlayer(contentsOf: alertSound2 as URL)
                } catch {
                    print("Playback error")
                }
                
                audioPlayer.volume = 0.07
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
                
            } else {
            
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
            } catch {
                print("Playback error")
            }
            
            audioPlayer.volume = 0.07
            audioPlayer.prepareToPlay()
            audioPlayer.play()
                
            }
            
        } else {
            print("sounds off")
        }
        
        navigationController!.popViewController(animated: true)
    }
    
    //What happens when delete is tapped.
    
    @IBAction func deleteItemTapped(_ sender: AnyObject) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let identifier = item?.notifid
        let twoWeekIdentifier = item?.twoweeknotifid
        let oneWeekIdentifier = item?.oneweeknotifid
        let twoDayIdentifier = item?.twodaynotifid
        
        //This is here to catch the 1.3.2 transition.
        
        if item?.notifid != nil {
            print("delete:: \(identifier!)")
        }
        if item?.twoweeknotifid != nil {
            print("two week delete:: \(twoWeekIdentifier!)")
        }
        if item?.oneweeknotifid != nil {
            print("one week delete:: \(oneWeekIdentifier!)")
        }
        if item?.twodaynotifid != nil {
            print("two day delete:: \(twoDayIdentifier!)")
        }
        
        context.delete(item!)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
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
        
        //SOUNDS
        
        //Create the alert sound
        
        let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "deleteSound", ofType: "mp3")!)
        
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
                try audioPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
            } catch {
                print("Playback error")
            }
            
            audioPlayer.volume = 0.07
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
        } else {
            print("sounds off")
        }
        
        navigationController!.popViewController(animated: true)
        
    }
    
    //Expiry date setup
    
    @IBAction func editingExpirationDateTextField(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(ItemViewController.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    //DATE CHANGED
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        //Sets it so the entered date is always UK regardless of region so the app doesn't crash when converting the date.
        dateFormatter.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        expirationDateTextField.text = dateFormatter.string(from: sender.date)
        
        //Send data to the notification func.
        selectedDate = sender.date
        twoWeeks = sender.date.addingTimeInterval(-1209600)
        oneWeek = sender.date.addingTimeInterval(-604800)
        twoDays = sender.date.addingTimeInterval(-172800)
        
        //print("Selected date: \(selectedDate)")
    }
    
    //What happens when Add to Shopping List is tapped.
    
    @IBAction func addToSLTapped(_ sender: AnyObject) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let SLItem = ShoppingListItem(context: context)
        SLItem.name = itemName.text
        SLItem.image = UIImageJPEGRepresentation(itemImage.image!, 0.05)! as Data?
        
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
                try audioPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
            } catch {
                print("Playback error")
            }
            
            audioPlayer.volume = 0.07
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
        } else {
            print("sounds off")
        }
        
        //Add badge to SL icon.
        
        for item in self.tabBarController!.tabBar.items! {
            if item.title == "Shopping List" {
                item.badgeValue = "New!"
            }
        }
        
        navigationController!.popViewController(animated: true)
    }
    
    //Dismiss the keyboard functions.
    
    @objc func dismissKeyboard() {
        
        //Dismiss the keyboard.
        itemName.resignFirstResponder()
        
        //Dismiss date picker.
        expirationDateTextField.resignFirstResponder()
    }
    
    //Dismiss the keyboard when return is tapped.
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        itemName.resignFirstResponder()
        return true
    }
    
    //Orientation setup.
    
    override func viewDidAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldSupportAllOrientation = false
    }
    
    @objc func imageTapped() {
        if itemImage.image != nil {
            performSegue(withIdentifier: "freezrBigPictureSegue", sender: nil)
        }
    }
    
    //Sets up the next ViewController (FreezerImageViewController) and sends some item data over.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "freezrBigPictureSegue" {
            
            let doneButton = UIBarButtonItem()
            doneButton.title = "Done"
            navigationItem.backBarButtonItem = doneButton
            
            let nextViewController = segue.destination as! FreezrImageViewController
            
            nextViewController.image = itemImage.image
            
        }
    }
    
    //Set up notifications.
    
    //Schedule inital notifications upon item creation.
    
    func scheduleNotification(at date: Date) {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Item expired"
        if (itemName.text?.isEmpty)! {
            content.body = "An item in your freezer has reached its expiry date."
        } else {
            content.body = "\(itemName.text!) has expired in your freezer."
        }
        content.sound = UNNotificationSound.init(named: "notifSound.mp3")
        
        let identifier = NSString.localizedUserNotificationString(forKey: "\(String(describing: today))", arguments: nil)
        
        print("Scheduled with::\(identifier)")
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {
            
            (error) in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    func pre2WeekNotification(at date: Date) {
        
        if UserDefaults.standard.bool(forKey: "preFreq2WeekTicked") == true {
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents(in: .current, from: date)
            let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = "Item expiring soon"
            if (itemName.text?.isEmpty)! {
                content.body = "An item in your freezer will expire in 2 weeks."
            } else {
                content.body = "\(itemName.text!) (in your freezer) will expire in 2 weeks."
            }
            content.sound = UNNotificationSound.init(named: "notifSound.mp3")
            
            let identifier = NSString.localizedUserNotificationString(forKey: "\(String(describing: today))" + "2week", arguments: nil)
            
            print("2 week Scheduled with::\(identifier)")
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {
                
                (error) in
                if let error = error {
                    print("Notification error: \(error)")
                }
            }
        } else {}
    }
    
    func pre1WeekNotification(at date: Date) {
        
        if UserDefaults.standard.bool(forKey: "preFreq1WeekTicked") == true {
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents(in: .current, from: date)
            let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = "Item expiring soon"
            if (itemName.text?.isEmpty)! {
                content.body = "An item in your freezer will expire in 1 week."
            } else {
                content.body = "\(itemName.text!) (in your freezer) will expire in 1 week."
            }
            content.sound = UNNotificationSound.init(named: "notifSound.mp3")
            
            let identifier = NSString.localizedUserNotificationString(forKey: "\(String(describing: today))" + "1week", arguments: nil)
            
            print("1 week Scheduled with::\(identifier)")
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {
                
                (error) in
                if let error = error {
                    print("Notification error: \(error)")
                }
            }
        } else {}
    }
    
    func pre2DayNotification(at date: Date) {
        
        if UserDefaults.standard.bool(forKey: "preFreq2DayTicked") == true {
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents(in: .current, from: date)
            let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = "Item expiring very soon"
            if (itemName.text?.isEmpty)! {
                content.body = "An item in your freezer will expire in just 2 days."
            } else {
                content.body = "\(itemName.text!) (in your freezer) will expire in just 2 days."
            }
            content.sound = UNNotificationSound.init(named: "notifSound.mp3")
            
            let identifier = NSString.localizedUserNotificationString(forKey: "\(String(describing: today))" + "2day", arguments: nil)
            
            print("2 day Scheduled with::\(identifier)")
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {
                
                (error) in
                if let error = error {
                    print("Notification error: \(error)")
                }
            }
        } else {}
    }
    
    //Schedule notifications upon item update.
    
    func updateScheduleNotification(at date: Date) {
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Item expired"
        if (itemName.text?.isEmpty)! {
            content.body = "An item in your freezer has reached its expiry date."
        } else {
            content.body = "\(itemName.text!) has expired in your freezer."
        }
        content.sound = UNNotificationSound.init(named: "notifSound.mp3")
        
        let identifier = NSString.localizedUserNotificationString(forKey: "\(String(describing: item!.notifid!))", arguments: nil)
        
        print("Update scheduled with::\(String(describing: identifier))")
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    func updatePre2WeekNotification(at date: Date) {
        
        if UserDefaults.standard.bool(forKey: "preFreq2WeekTicked") == true {
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents(in: .current, from: date)
            let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = "Item expiring soon"
            if (itemName.text?.isEmpty)! {
                content.body = "An item in your freezer will expire in 2 weeks."
            } else {
                content.body = "\(itemName.text!) (in your freezer) will expire in 2 weeks."
            }
            content.sound = UNNotificationSound.init(named: "notifSound.mp3")
            
            let identifier = NSString.localizedUserNotificationString(forKey: "\(String(describing: item!.notifid!))" + "2week", arguments: nil)
            
            print("Update 2 week Scheduled with::\(identifier)")
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {
                
                (error) in
                if let error = error {
                    print("Notification error: \(error)")
                }
            }
        } else {}
    }
    
    func updatePre1WeekNotification(at date: Date) {
        
        if UserDefaults.standard.bool(forKey: "preFreq1WeekTicked") == true {
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents(in: .current, from: date)
            let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = "Item expiring soon"
            if (itemName.text?.isEmpty)! {
                content.body = "An item in your freezer will expire in 1 week."
            } else {
                content.body = "\(itemName.text!) (in your freezer) will expire in 1 week."
            }
            content.sound = UNNotificationSound.init(named: "notifSound.mp3")
            
            let identifier = NSString.localizedUserNotificationString(forKey: "\(String(describing: item!.notifid!))" + "1week", arguments: nil)
            
            print("Update 1 week Scheduled with::\(identifier)")
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {
                
                (error) in
                if let error = error {
                    print("Notification error: \(error)")
                }
            }
        } else {}
    }
    
    func updatePre2DayNotification(at date: Date) {
        
        if UserDefaults.standard.bool(forKey: "preFreq2DayTicked") == true {
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents(in: .current, from: date)
            let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = "Item expiring very soon"
            if (itemName.text?.isEmpty)! {
                content.body = "An item in your freezer will expire in just 2 days."
            } else {
                content.body = "\(itemName.text!) (in your freezer) will expire in just 2 days."
            }
            content.sound = UNNotificationSound.init(named: "notifSound.mp3")
            
            let identifier = NSString.localizedUserNotificationString(forKey: "\(String(describing: item!.notifid!))" + "2day", arguments: nil)
            
            print("Update 2 day Scheduled with::\(identifier)")
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) {
                
                (error) in
                if let error = error {
                    print("Notification error: \(error)")
                }
            }
        } else {}
    }
    
    //Setup empty text/image alert.
    
    func showTextErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Hold on a second!", message: "You have to give the item a name or an image before adding it to your freezer!", preferredStyle: .alert)
        let cont = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(cont)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    //Final declaration:
    
}
