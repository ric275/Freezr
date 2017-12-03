//
//  AboutViewController.swift
//  Freezr
//
//  Created by Jack Taylor on 13/10/2016.
//  Copyright © 2016-2017 Jack Taylor. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    //Custom colours.
    
    let myPurple:UIColor = UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0)
    
    //Outlets - loads of label outlets because I'm too lazy to change the text colour in the storyboard.
    
    @IBOutlet var aboutView: UIView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    
    @IBOutlet weak var img4: UIButton!
    
    //Variables.
    
    var tapCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        aboutView.backgroundColor = myPurple
        label1.textColor = .white
        label2.textColor = .white
        label3.textColor = .white
        label4.textColor = .white
        label5.textColor = .white
        label6.textColor = .white
        label7.textColor = .white
        
    }
    
    @IBAction func easterEggTapped(_ sender: AnyObject) {
        
        tapCount = tapCount + 1
        
        
        if tapCount == 7 {
            label1.text = "Meow Meow"
            label2.text = "Meow Meow"
            label3.text = "Meow Meow"
            label4.text = "Meow Meow"
            label5.text = "Meow Meow"
            label6.text = "Meow Meow"
            label7.text = "🐱🐱🐱"
            aboutView.backgroundColor = UIColor(patternImage: UIImage(named: "tigger")!)
            img4.isHidden = true
            
        } else {}
        
    }
    
    //Orientation setup.
    
    override func viewDidAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.shouldSupportAllOrientation = false
    }
    
    //Final declaration:
    
}
