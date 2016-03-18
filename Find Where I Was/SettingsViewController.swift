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
    func updateSettingOpenMarkerDetailsAfterSearch(data: Bool)
    func updateSettingShowCompass(data: Bool)
    func updateSettingShowScale(data: Bool)
    func updateSettingShowTraffic(data: Bool)
    func updateSettingMapType(data: Int)
    
    func loadSettings()
    func saveSettings()
}


class SettingsViewController: UITableViewController {

    var delegate: SettingsDelegate?   
    
    @IBOutlet weak var OutletDefaultMarkerName: UISegmentedControl!
    @IBOutlet weak var OutletAutoPanOnLoad: UISwitch!
    @IBOutlet weak var OutletMarkerDetailsAfterSearch: UISwitch!
    @IBOutlet weak var OutletShowCompass: UISwitch!
    @IBOutlet weak var OutletShowTraffic: UISwitch!
    @IBOutlet weak var OutletShowScale: UISwitch!
    @IBOutlet weak var OutletMapType: UISegmentedControl!
    
    
    
    @IBAction func doneButton(sender: AnyObject) {
        //print ("Done button clicked")
        
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
    
    @IBAction func MarkerDetailsAfterSearch(sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        if let tempBool : Bool = mySwitch.on
        {
            delegate?.updateSettingOpenMarkerDetailsAfterSearch(tempBool)
        }
    }
    
    @IBAction func ShowCompass(sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        if let tempBool : Bool = mySwitch.on
        {
            delegate?.updateSettingShowCompass(tempBool)
        }
    }
    
    @IBAction func ShowTraffic(sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        if let tempBool : Bool = mySwitch.on
        {
            delegate?.updateSettingShowTraffic(tempBool)
        }
    }
    
    @IBAction func ShowScale(sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        if let tempBool : Bool = mySwitch.on
        {
            delegate?.updateSettingShowScale(tempBool)
        }
    }
    
    @IBAction func MapTypeChanged(sender: AnyObject) {
            delegate?.updateSettingMapType(sender.selectedSegmentIndex)
        
    }
    
    
    @IBAction func deleteAllUserData(sender: AnyObject) {
        
        let myAlert = UIAlertController(title: "Are You Sure?", message: "Are you sure you wish to delete all user data? This cannot be undone", preferredStyle:UIAlertControllerStyle.Alert)
        let yes = UIAlertAction(title: "Yes", style:.Default, handler: {(alert:
            UIAlertAction!) in
            print("Yes button was pressed")
            
            //Delete User data
           
            
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
            
            
            //Erase Array of data
            MarkedPointArr = []
            
            

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
    
    override func viewWillAppear(animated: Bool) {
        
        //For Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Settings")
        
        let eventTracker: NSObject = GAIDictionaryBuilder.createScreenView().build()
        tracker.send(eventTracker as! [NSObject : AnyObject])
        //For Google Analytics
        
        super.viewWillAppear(animated)
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
        
        if settingOpenMarkerDetailsAfterSearch
        {
            OutletMarkerDetailsAfterSearch.on = true
        }
        else
        {
            OutletMarkerDetailsAfterSearch.on = false
        }
        
        if settingShowCompass
        {
            OutletShowCompass.on = true
        }
        else
        {
            OutletShowCompass.on = false
        }
        
        if settingShowTraffic
        {
            OutletShowTraffic.on = true
        }
        else
        {
            OutletShowTraffic.on = false
        }
        
        if settingShowScale
        {
            OutletShowScale.on = true
        }
        else
        {
            OutletShowScale.on = false
        }
        
        if settingDefaultMarkerdPointName == 0
        {
            OutletDefaultMarkerName.selectedSegmentIndex = 0
        }
        
        if settingDefaultMarkerdPointName == 1
        {
            OutletDefaultMarkerName.selectedSegmentIndex = 1
        }
        
        if settingMapType == "Standard"
        {
            OutletMapType.selectedSegmentIndex = 0
        }
        if settingMapType == "Satellite"
        {
            OutletMapType.selectedSegmentIndex = 1
        }
        if settingMapType == "Hybrid"
        {
            OutletMapType.selectedSegmentIndex = 2
        }

    }
    
}
