		//
//  PopoverViewController.swift
//  Where Was I
//
//  Created by Glenn McCartney on 19/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//
import UIKit
import CoreLocation
import MapKit
import AudioToolbox

protocol MarkedLocationDelegate {
    func updateData(data: String)
    func deleteData(data: Bool)
    func takeMeHere(data: MKMapItem)
}

class PopoverContentViewController: UIViewController {
   
    
    var delegate: MarkedLocationDelegate?
    var originalMarkedLocationName : String?
    var markedLocationLat : String?
    var markedLocationLng : String?
    var MapItem : MKMapItem?
    
    @IBOutlet weak var markedLocationName: UITextField!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var EstimatedAddress: UILabel!
    
    @IBOutlet weak var outletTakeMeHere: UIButton!
    
    @IBOutlet weak var outletSaveButton: UIButton!
    
  	

    
    @IBAction func textEditingChanged(sender: AnyObject) {

        //Dont allow the name to be saved if itis empty or it already exisits.
        if ((markedLocationName.text! != "") && (!checkIfNameExisits(markedLocationName.text!)))
        {
            outletSaveButton.enabled = true
        }
        else
        {
            outletSaveButton.enabled = false
        }
    }
    
    
    @IBAction func BackButton(sender: AnyObject) {
        
        self.performSegueWithIdentifier("unwindIdentifier", sender: self)
    }
    
    
    
    @IBAction func saveButton(sender: AnyObject) {
        
        //check if the name already exists...
        var boolNameAlready = false
        
        for MarkedPoint in MarkedPointArr
        {
            //Does the selected name exist?
            if  MarkedPoint.name == markedLocationName.text!
            {
                boolNameAlready = true
            }
        }
        

        if boolNameAlready
        {
            addressLabel.text = "Try another name"
            EstimatedAddress.text = "Name Already Exists"
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        else
        {
            addressLabel.text = ""
            EstimatedAddress.text = ""
            self.delegate?.updateData(markedLocationName.text!)
            self.performSegueWithIdentifier("unwindIdentifier", sender: self)
        }
    
    }
    
    
    @IBAction func deleteButton(sender: AnyObject) {
        print ("delete clicked")
        
        //To-Do : Add an "Are You sure?" message
        
        
        let myAlert = UIAlertController(title: "Are you sure?", message: "Are you sure you wish to delete this marker?", preferredStyle:UIAlertControllerStyle.Alert)
        let yes = UIAlertAction(title: "Yes", style:.Default, handler: {(alert:
            UIAlertAction!) in
            
            self.delegate?.deleteData(true)
            self.performSegueWithIdentifier("unwindIdentifier", sender: self)
        })
        let no = UIAlertAction(title: "No", style:.Default, handler: {(alert:
            UIAlertAction!) in
            //do nothing!
            
        })
        
        myAlert.addAction(no)
        myAlert.addAction(yes)
        
        presentViewController(myAlert, animated: true, completion: nil)
      
    }
    
    
    @IBAction func takeMeHereButton(sender: AnyObject) {
        self.delegate?.takeMeHere(MapItem!)
        self.performSegueWithIdentifier("unwindIdentifier", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        outletTakeMeHere.enabled = false
        
        outletSaveButton.enabled = false
        
        if let omln = originalMarkedLocationName {
            markedLocationName.text = omln
        }
        else {
            print("empty selection")
        }
        
        //Default text for label is empty, in case the Reverse Geocode doesnt work
        addressLabel.text = ""
        EstimatedAddress.text = ""
        
        //Reverse Geocode
        
        print (markedLocationLat)
        print (markedLocationLng)
        
        let myDoubleLat = Double(markedLocationLat!)
        let myDoubleLng = Double(markedLocationLng!)
        
        
        let location = CLLocation(latitude : myDoubleLat!, longitude: myDoubleLng!)
        
        CLGeocoder().reverseGeocodeLocation(location,
            completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    self.addressLabel.text = self.formatAddressFromPlacemark(placemark)
                    self.EstimatedAddress.text = "Estimated Address :"
                    
                    
                    //for the take me here function
                    self.MapItem = MKMapItem(placemark:  MKPlacemark(coordinate: placemark.location!.coordinate,
                        addressDictionary: placemark.addressDictionary as! [String:AnyObject]?))
                    
                    self.outletTakeMeHere.enabled = true
                }
        })
        
        
      
        
    }
    
    func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as!
            [String]).joinWithSeparator(", ")
    }
    
  
}
