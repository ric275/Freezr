//
//  AddToSLViewController.swift
//  Freezr
//
//  Created by Jack Taylor on 30/11/2017.
//  Copyright © 2017-2018 Jack Taylor. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

class AddToSLViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    //Custom colours.
    
    let myPurple:UIColor = UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0)
    
    let newPurple:UIColor = UIColor(red: 125/255.0, green: 80/255.0, blue: 230/255.0, alpha: 1.0)
    
    let newPurple2:UIColor = UIColor(red: 146/255.0, green: 54/255.0, blue: 240/255.0, alpha: 1.0)
    
    //Outlets.
    
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var itemName: UITextField!
    
    @IBOutlet weak var placeHolderText1: UILabel!
    
    @IBOutlet weak var placeHolderText2: UILabel!
    
    @IBOutlet weak var addToSLButton: UIButton!
    
    @IBOutlet weak var imageNoticeText: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    //Variables.
    
    var imageSelector = UIImagePickerController()
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageSelector.delegate = self
        
        itemName.delegate = self
        
        itemName.returnKeyType = UIReturnKeyType.done
        
        itemName.textColor = newPurple2
        
        addToSLButton.tintColor = newPurple2
        
        placeHolderText1.textColor = newPurple2
        
        placeHolderText2.textColor = newPurple2
        
        
        //Dismiss the keyboard when tapped away (setup).
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ItemViewController.dismissKeyboard)))
    }
    
    //Select image methods.
    
    @IBAction func photosTapped(_ sender: AnyObject) {
        imageSelector.sourceType = .photoLibrary
        imageSelector.allowsEditing = true
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
        
    }
    
    //What happens when Add to Shopping List is tapped.
    
    @IBAction func addToSLTapped(_ sender: AnyObject) {
        
        if (itemName.text?.isEmpty)! {
            showTextErrorAlert()
        } else {
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let SLItem = ShoppingListItem(context: context)
            let defaultImage = UIImage(named: "shoppingListTemp")
            SLItem.name = itemName.text
            SLItem.isChecked = false
            
            if itemImage.image == nil {
                SLItem.image = UIImageJPEGRepresentation(defaultImage!, 0.05)! as Data?
            } else {
                SLItem.image = UIImageJPEGRepresentation(itemImage.image!, 0.05)! as Data?
            }
            
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
    }
    
    //Dismiss the keyboard functions.
    
    @objc func dismissKeyboard() {
        
        //Dismiss the keyboard.
        itemName.resignFirstResponder()
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
    
    //Setup empty text alert.
    
    func showTextErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Hold on a second!", message: "You have to give the item a name before adding it to your shopping list!", preferredStyle: .alert)
        let cont = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(cont)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    //Final declaration:
    
}
