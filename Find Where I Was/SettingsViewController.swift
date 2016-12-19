//
//  SettingsViewController.swift
//  Where Was I
//
//  Created by Glenn McCartney on 20/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//

import UIKit


protocol SettingsDelegate {
    func updateDefaultMarkerName(_ data: Int)
    func updateSettingPanToCurrentLocationOnOpen(_ data: Bool)
    func updateSettingDeleteAllUserData(_ data: Bool)
    func updateSettingOpenMarkerDetailsAfterSearch(_ data: Bool)
    func updateSettingShowCompass(_ data: Bool)
    func updateSettingShowScale(_ data: Bool)
    func updateSettingShowTraffic(_ data: Bool)
    func updateSettingMapType(_ data: Int)
    
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
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnDeleteAll: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        btnDone.layer.cornerRadius = 6
        btnDone.layer.borderWidth = 1
        btnDone.layer.borderColor = self.view.tintColor.cgColor
        
        
        btnDeleteAll.layer.cornerRadius = 6
        btnDeleteAll.layer.borderWidth = 1
        btnDeleteAll.layer.borderColor = self.view.tintColor.cgColor
        
        reloadSettings()
    }
    
    
    @IBAction func doneButton(_ sender: AnyObject) {
        //print ("Done button clicked")
        
        delegate?.saveSettings()
        
        self.performSegue(withIdentifier: "unwindIdentifier", sender: self)
    }
    
    
    @IBAction func DefaultMarkerName(_ sender: AnyObject) {
        delegate?.updateDefaultMarkerName(sender.selectedSegmentIndex)
        
     }
    
    @IBAction func PanOnOpen(_ sender: AnyObject) {
        let mySwitch = sender as! UISwitch
         let tempBool : Bool = mySwitch.isOn
            delegate?.updateSettingPanToCurrentLocationOnOpen(tempBool)
        
    }
    
    @IBAction func MarkerDetailsAfterSearch(_ sender: AnyObject) {
        let mySwitch = sender as! UISwitch
         let tempBool : Bool = mySwitch.isOn
        
        delegate?.updateSettingOpenMarkerDetailsAfterSearch(tempBool)
        
    }
    
    @IBAction func ShowCompass(_ sender: AnyObject) {
        let mySwitch = sender as! UISwitch
        let tempBool : Bool = mySwitch.isOn
        
            delegate?.updateSettingShowCompass(tempBool)
        
    }
    
    @IBAction func ShowTraffic(_ sender: AnyObject) {
        let mySwitch = sender as! UISwitch
         let tempBool : Bool = mySwitch.isOn
        
            delegate?.updateSettingShowTraffic(tempBool)
        
    }
    
    @IBAction func ShowScale(_ sender: AnyObject) {
        let mySwitch = sender as! UISwitch
         let tempBool : Bool = mySwitch.isOn
        
            delegate?.updateSettingShowScale(tempBool)
        
    }
    
    @IBAction func MapTypeChanged(_ sender: AnyObject) {
            delegate?.updateSettingMapType(sender.selectedSegmentIndex)
        
    }
    
    
    @IBAction func deleteAllUserData(_ sender: AnyObject) {
        
        let myAlert = UIAlertController(title: "Are You Sure?", message: "Are you sure you wish to delete all user data? This cannot be undone", preferredStyle:UIAlertControllerStyle.alert)
        let yes = UIAlertAction(title: "Yes", style:.default, handler: {(alert:
            UIAlertAction!) in
            //print("Yes button was pressed")
            
            //Delete User data
           
            
            let fileManager = FileManager.default
            
            do{
                try
                
                    fileManager.removeItem(atPath: pathToFile(kFileName)!.path)
                    //print("Remove 1 successful")
   
            }
            catch let error as NSError
            {
                print("Remove failed: \(error.localizedDescription)")
            }
            
            
            do{
                try
                    
                    fileManager.removeItem(atPath: pathToFile(kSettingsFileName)!.path)
                //print("Remove 2 successful")
                
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
        let no = UIAlertAction(title: "No", style:.default, handler: {(alert: UIAlertAction!) in
            
            //print("No button was pressed")
            //Do Nothing...
        })
        
        myAlert.addAction(no)
        myAlert.addAction(yes)
        
        present(myAlert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //For Google Analytics
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Settings")
        
        let eventTracker: NSObject = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(eventTracker as! [AnyHashable: Any])
        //For Google Analytics
        
        super.viewWillAppear(animated)
    }
    
    func reloadSettings()
    {
        if settingPanToCurrentLoctionOnOpen
        {
            OutletAutoPanOnLoad.isOn = true
        }
        else
        {
            OutletAutoPanOnLoad.isOn = false
        }
        
        if settingOpenMarkerDetailsAfterSearch
        {
            OutletMarkerDetailsAfterSearch.isOn = true
        }
        else
        {
            OutletMarkerDetailsAfterSearch.isOn = false
        }
        
        if settingShowCompass
        {
            OutletShowCompass.isOn = true
        }
        else
        {
            OutletShowCompass.isOn = false
        }
        
        if settingShowTraffic
        {
            OutletShowTraffic.isOn = true
        }
        else
        {
            OutletShowTraffic.isOn = false
        }
        
        if settingShowScale
        {
            OutletShowScale.isOn = true
        }
        else
        {
            OutletShowScale.isOn = false
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
