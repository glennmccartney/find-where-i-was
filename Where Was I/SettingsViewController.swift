//
//  SettingsViewController.swift
//  Where Was I
//
//  Created by Glenn McCartney on 20/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//

import UIKit


protocol SettingsDelegate {
    func updateDefaultMarkerName(data: Int)
    func updateSettingPanToCurrentLocationOnOpen(data: Bool)
    func updateSettingDeleteAllUserData(data: Bool)
    func loadSettings()
    func saveSettings()
}


class SettingsViewController: UIViewController {

    var delegate: SettingsDelegate?
    
    
    @IBOutlet weak var OutletDefaultMarkerName: UISegmentedControl!
    @IBOutlet weak var OutletAutoPanOnLoad: UISwitch!
    
    
    @IBAction func doneButton(sender: AnyObject) {
        print ("Done button clicked")
        
        //self.delegate?.updateData(markedLocationName.text!)
        delegate?.saveSettings()
        
        self.performSegueWithIdentifier("unwindIdentifier", sender: self)
    }
    
    
    @IBAction func DefaultMarkerName(sender: AnyObject) {
        delegate?.updateDefaultMarkerName(sender.selectedSegmentIndex)
        
     }
    
    @IBAction func PanOnOpen(sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        
        if let tempBool : Bool = mySwitch.on
        {
            delegate?.updateSettingPanToCurrentLocationOnOpen(tempBool)
        }
        
    }
    
    @IBAction func deleteAllUserData(sender: AnyObject) {
        
        let myAlert = UIAlertController(title: "Are You Sure?", message: "Are you sure you wish to delete all user data? This cannot be undone", preferredStyle:UIAlertControllerStyle.Alert)
        let yes = UIAlertAction(title: "Yes", style:.Default, handler: {(alert:
            UIAlertAction!) in
            print("Yes button was pressed")
            
            //Delete User data
            
            //Save data
            
            //let myArray = NSMutableArray()
            //print ("Saving No Data...")
            //myArray.writeToURL(pathToFile(kFileName)!, atomically: true)
            
            
            
            let fileManager = NSFileManager.defaultManager()
            
            do{
                try
                
                    fileManager.removeItemAtPath(pathToFile(kFileName)!.path!)
                    print("Remove 1 successful")
   
            }
             catch let error as NSError
             {
                print("Remove failed: \(error.localizedDescription)")
            }
            
            
            do{
                try
                    
                    fileManager.removeItemAtPath(pathToFile(kSettingsFileName)!.path!)
                print("Remove 2 successful")
                
            }
            catch let error as NSError
            {
                print("Remove failed: \(error.localizedDescription)")
            }
            
            //Remove Markup
            self.delegate?.updateSettingDeleteAllUserData(true)
            
            //Load settings to get default vaules back
            self.delegate?.loadSettings()
            
            self.reloadSettings()
            
        })
        let no = UIAlertAction(title: "No", style:.Default, handler: {(alert:
            UIAlertAction!) in
            print("No button was pressed")
            //Do Nothing...
        })
        
        myAlert.addAction(no)
        myAlert.addAction(yes)
        
        presentViewController(myAlert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        reloadSettings()
    }
    
    func reloadSettings()
    {
        if settingPanToCurrentLoctionOnOpen
        {
            OutletAutoPanOnLoad.on = true
        }
        else
        {
            OutletAutoPanOnLoad.on = false
        }
        
        if settingDefaultMarkerdPointName == 0
        {
            OutletDefaultMarkerName.selectedSegmentIndex = 0
        }
        
        if settingDefaultMarkerdPointName == 1
        {
            OutletDefaultMarkerName.selectedSegmentIndex = 1
        }

    }
    
}
