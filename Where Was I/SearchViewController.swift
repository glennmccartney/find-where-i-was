//
//  SearchViewController.swift
//  Where Was I
//
//  Created by Glenn McCartney on 20/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    
    @IBAction func donebutton(sender: AnyObject) {
        print ("Done button clicked")
        
        //self.delegate?.updateData(markedLocationName.text!)
        self.performSegueWithIdentifier("unwindIdentifier", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
