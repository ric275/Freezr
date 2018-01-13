//
//  FridgeImageViewController.swift
//  Freezr
//
//  Created by Jack Taylor on 02/11/2016.
//  Copyright © 2016-2018 Jack Taylor. All rights reserved.
//

import UIKit

class FridgeImageViewController: UIViewController {
    
    var image:UIImage? = nil

    @IBOutlet weak var bigImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if image != nil {
            bigImage.image = image
        } else {
            print("ERROR LOADING BIG IMAGE - the image was nil!")
        }
    }
}
