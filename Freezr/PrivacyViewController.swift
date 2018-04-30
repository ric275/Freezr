//
//  PrivacyViewController.swift
//  Freezr
//
//  Created by Jack Taylor on 30/04/2018.
//  Copyright © 2016-2018 Jack Taylor. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
    
    //Custom colours.
    
    let myPurple:UIColor = UIColor(red: 105/255.0, green: 94/255.0, blue: 133/255.0, alpha: 1.0)
    
    let newPurple2:UIColor = UIColor(red: 146/255.0, green: 54/255.0, blue: 240/255.0, alpha: 1.0)
    
    //Outlets
    
    @IBOutlet var privacyView: UIView!
    
    @IBOutlet weak var text: UILabel!
    
    @IBOutlet weak var GDPRicon: UIImageView!
    
    //Variables.
    
    var tapCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        privacyView.backgroundColor = newPurple2
        text.textColor = .white
        
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
