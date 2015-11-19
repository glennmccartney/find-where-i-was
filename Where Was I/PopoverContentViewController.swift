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
    
    @IBAction func saveButton(sender: AnyObject) {
        
        print ("button clicked. Value is \(markedLocationName.text)")
        
        self.delegate?.updateData(markedLocationName.text!)
        self.performSegueWithIdentifier("unwindIdentifier", sender: self)
    }
    
    
    @IBAction func deleteButton(sender: AnyObject) {
        print ("delete clicked")
        
        //To-Do : Add an "Are You sure?" message
        self.delegate?.deleteData(true)
        self.performSegueWithIdentifier("unwindIdentifier", sender: self)
    }
    
    
    @IBAction func takeMeHereButton(sender: AnyObject) {
        self.delegate?.takeMeHere(MapItem!)
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
                    
                    self.MapItem = MKMapItem(placemark:  MKPlacemark(coordinate: placemark.location!.coordinate,
                        addressDictionary: placemark.addressDictionary as! [String:AnyObject]?))
                }
        })
        
    }
    
    func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as!
            [String]).joinWithSeparator(", ")
    }
    
}
