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
    func updateData(_ data: String)
    func deleteData(_ data: Bool)
    func takeMeHere(_ data: MKMapItem)
}

class PopoverContentViewController: UIViewController {
   
    
    var delegate: MarkedLocationDelegate?
    var originalMarkedLocationName : String? = nil
    var markedLocationLat : String?
    var markedLocationLng : String?
    var MapItem : MKMapItem?
    
    @IBOutlet weak var markedLocationName: UITextField!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var EstimatedAddress: UILabel!
    
    @IBOutlet weak var outletTakeMeHere: UIButton!
    
    @IBOutlet weak var outletSaveButton: UIButton!
    
  	

    
    @IBAction func textEditingChanged(_ sender: AnyObject) {

        //Dont allow the name to be saved if itis empty or it already exisits.
        if ((markedLocationName.text! != "") && (!checkIfNameExisits(markedLocationName.text!)))
        {
            outletSaveButton.isEnabled = true
        }
        else
        {
            outletSaveButton.isEnabled = false
        }
    }
    
    
    @IBAction func BackButton(_ sender: AnyObject) {
        
        self.performSegue(withIdentifier: "unwindIdentifier", sender: self)
    }
    
    
    
    @IBAction func saveButton(_ sender: AnyObject) {
        
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
            self.performSegue(withIdentifier: "unwindIdentifier", sender: self)
        }
    
    }
    
    
    @IBAction func deleteButton(_ sender: AnyObject) {
        print ("delete clicked")
        
        //To-Do : Add an "Are You sure?" message
        
        
        let myAlert = UIAlertController(title: "Are you sure?", message: "Are you sure you wish to delete this marker?", preferredStyle:UIAlertController.Style.alert)
        let yes = UIAlertAction(title: "Yes", style:.default, handler: {(alert:
            UIAlertAction!) in
            
            self.delegate?.deleteData(true)
            self.performSegue(withIdentifier: "unwindIdentifier", sender: self)
        })
        let no = UIAlertAction(title: "No", style:.default, handler: {(alert:
            UIAlertAction!) in
            //do nothing!
            
        })
        
        myAlert.addAction(no)
        myAlert.addAction(yes)
        
        present(myAlert, animated: true, completion: nil)
      
    }
    
    
    @IBAction func takeMeHereButton(_ sender: AnyObject) {
        self.delegate?.takeMeHere(MapItem!)
        self.performSegue(withIdentifier: "unwindIdentifier", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        outletTakeMeHere.isEnabled = false
        
        outletSaveButton.isEnabled = false
        
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
        
        //print (markedLocationLat!)
        //print (markedLocationLng!)
        
        let myDoubleLat = Double(markedLocationLat!)
        let myDoubleLng = Double(markedLocationLng!)
        
        
        let location = CLLocation(latitude : myDoubleLat!, longitude: myDoubleLng!)
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error)  in
                if let placemarks = placemarks {
                    let placemark = placemarks[0]
                    self.addressLabel.text = self.formatAddressFromPlacemark(placemark)
                    self.EstimatedAddress.text = "Estimated Address :"
                    
                    
                    //for the take me here function
                    self.MapItem = MKMapItem(placemark:  MKPlacemark(coordinate: placemark.location!.coordinate,
                        addressDictionary: nil))
                    
                    self.outletTakeMeHere.isEnabled = true
                }
        }
        
        
      
        
    }
    
    func formatAddressFromPlacemark(_ placemark: CLPlacemark) -> String {
        
        let address = "\(placemark.subThoroughfare ?? ""), \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.subLocality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
        
        return (address)
    }
    
  
}
