//
//  PopoverViewController.swift
//  Where Was I
//
//  Created by Glenn McCartney on 19/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//
import UIKit

protocol MarkedLocationDelegate {
    func updateData(data: String)
}

class PopoverContentViewController: UIViewController {

    var delegate: MarkedLocationDelegate?
    
    var originalMarkedLocationName : String?
    
    
    @IBOutlet weak var markedLocationName: UITextField!
    
    
    @IBAction func saveButton(sender: AnyObject) {
        //myPopoverPresentationController.delegate = nil
        //myPopoverPresentationController = nil
        //myPopoverController = nil
        
        
        print ("button clicked")
        print ("value is \(markedLocationName.text)")
        
        self.delegate?.updateData(markedLocationName.text!)
        
        
         self.performSegueWithIdentifier("unwindIdentifier", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        if let omln = originalMarkedLocationName {
        
            markedLocationName.text = omln
            
        }
        else {
            print("empty selection")
        }

    }
    
}
