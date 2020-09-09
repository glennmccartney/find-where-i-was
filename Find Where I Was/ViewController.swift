//
//  ViewController.swift
//  Find Where I Was
//
//  Created by Glenn McCartney on 17/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMobileAds
import Firebase

//User Settings
var settingDefaultMarkerdPointName : Int = 1
var settingPanToCurrentLoctionOnOpen : Bool = true
var settingOpenMarkerDetailsAfterSearch: Bool = false
var settingShowCompass: Bool = true
var settingShowTraffic: Bool = true
var settingShowScale: Bool = true
var settingMapType: String = "Standard"

//Static Settings
let kFileName = "savedData.plist"
let kSettingsFileName = "savedSettingsData.plist"
let defaultSettingsfileName = "DefaultSettings"

//Global Vars
var MarkedPointArr = [] as [MarkedPoint]

//Custom Classes Start ------------------------------------------
class MKPointAnnotationCustom: MKPointAnnotation  {
    var userData: Int?
}

class MarkedPoint {
    var name = ""
    var id = 0
    var lat = 0.0 as Double
    var lng = 0.0 as Double
    
    init(name: String, id : Int, lat : Double, lng : Double)
    {
        self.name = name
        self.id = id
        self.lat = lat
        self.lng = lng
    }
    
}
//Custom Classes End ------------------------------------------


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GADInterstitialDelegate {
    var boolGotoDetailsOnviewDidLoad : Bool = false
    var boolAutoPanOnResume : Bool = false
    var boolAutoPan : Bool = true
    var boolShowNoLocationAlert : Bool?
    var locationManager = CLLocationManager()
    var marklocation = CLLocationCoordinate2D()
    var locationPointAnnotation = MKPointAnnotation()
    var userZoom : Double = 0
    var circle : MKCircle?
    
    var markedPointAnnotations = [] as  [MKPointAnnotationCustom]
    var currentSelectedMarkedPointAnnotation = MKPointAnnotationCustom()
    var currentSelectedMarkedPointElementId : Int?
    
    var locationTuples: [(textField: UITextField?, mapItem: MKMapItem?)]!
    var currentLocation : CLLocationCoordinate2D?
    var sourceMapItem : MKMapItem?
    var displayedPolyline : MKOverlay?
    
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var autoPan: UISwitch!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadSettings()
        
        if settingShowCompass
        {
            myMapView.showsCompass = true
        }
        
        if settingShowScale
        {
            myMapView.showsScale = true
        }
        
        if settingShowTraffic
        {
            myMapView.showsTraffic = true
        }
        
        if settingMapType == "Standard"
        {
            myMapView.mapType = MKMapType.standard
        }
        if settingMapType == "Hybrid"
        {
            myMapView.mapType = MKMapType.hybrid
        }
        if settingMapType == "Satellite"
        {
            myMapView.mapType = MKMapType.satellite
        }
        
        myMapView.showsUserLocation = true
        
        
        if FileManager.default.fileExists(atPath: pathToFile(kFileName)!.path)
        {
            
            let myArray = NSArray(contentsOf: pathToFile(kFileName)!) as! [String]
            
            
            //print ("Loading data...")
            
            
            for element in myArray {
                
                //print("\(element) ")
                
                let fullArr = element.components(separatedBy: ",")
                let myDoubleLat = Double(fullArr[1])
                let myDoubleLng = Double(fullArr[2])
                
                //Commas have been saved as *|* so swap them back
                let newStringTitle = fullArr[3].replacingOccurrences(of: "*|*", with: ",")
                
                let tempMarkedPoint = MarkedPoint(name: newStringTitle, id : Int(fullArr[0])!, lat: myDoubleLat!, lng: myDoubleLng!)
                
                
                let location  = CLLocationCoordinate2D(latitude : tempMarkedPoint.lat, longitude: tempMarkedPoint.lng)
                
                let pointAnnotation = MKPointAnnotationCustom()
                pointAnnotation.coordinate = location
                
                
                pointAnnotation.title = tempMarkedPoint.name
                pointAnnotation.userData = tempMarkedPoint.id
                
                myMapView.addAnnotation(pointAnnotation)
                
                MarkedPointArr.append(tempMarkedPoint)
                markedPointAnnotations.append(pointAnnotation)
            }
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name:UIApplication.didEnterBackgroundNotification, object:UIApplication.shared)
        //applicationDidBecomeActive
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)), name:UIApplication.didBecomeActiveNotification, object:UIApplication.shared)
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            locationManager.activityType = CLActivityType.fitness
            
            statusLabel.text = "Searching For Your Location..."
        }

        self.interstitial = createAndLoadInterstitial()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //if the condition to open the details view has been set
        if boolGotoDetailsOnviewDidLoad == true
        {
            //reset it first...
            boolGotoDetailsOnviewDidLoad = false
            //Go
            self.performSegue(withIdentifier: "ShowPopoverFromPin", sender: self)
        }
        
    }
    
    @IBAction func toggleAutoPan(_ sender: AnyObject) {
        boolAutoPan = !boolAutoPan
    }
    
    @IBAction func returned(_ segue: UIStoryboardSegue)
    {
        if ((boolShowNoLocationAlert) != nil)
        {
            let myAlert = UIAlertController(title: "My Alert", message: "Your Current Loction is Unknown", preferredStyle:UIAlertController.Style.alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: {(alert:
                UIAlertAction!) in
                print("OK button was pressed")
            })
            myAlert.addAction(ok)
            
            present(myAlert, animated: true, completion: nil)
        }
        
        if segue.identifier == "unwindSearchIdentifier"
        {
            if let searchController = segue.source as? SearchViewController
            {
                if (searchController.OpenMarkerDetailsForEdit)
                {
                    
                    //try and find the Marked Point by looping through all and the map and matching the name
                    for MarkedPoint in MarkedPointArr
                    {
                        //If a Marked Point has been selected...
                        if let sm = searchController.selectedMark
                        {
                            if MarkedPoint.name  == sm
                            {
                                currentSelectedMarkedPointAnnotation = markedPointAnnotations[MarkedPoint.id]
                                
                                boolGotoDetailsOnviewDidLoad = true
                            }
                            
                        }
                    }
                    
                    //reset value back to false
                    searchController.OpenMarkerDetailsForEdit = false
                }
                
                
                //try and find the Marked Point by looping through all and the map and matching the name
                for MarkedPoint in MarkedPointArr
                {
                    //If a Marked Point has been selected...
                    if let sm = searchController.selectedMark
                    {
                        if MarkedPoint.name  == sm
                        {
                            currentLocation = CLLocationCoordinate2D(latitude : MarkedPoint.lat, longitude: MarkedPoint.lng)
                            
                            let myRegion = MKCoordinateRegion.init(center: currentLocation!, latitudinalMeters: (locationManager.location?.horizontalAccuracy)!, longitudinalMeters: (locationManager.location?.horizontalAccuracy)!)
                            
                            myMapView.setRegion(myRegion, animated: true)
                            
                            boolAutoPan = false
                            autoPan.setOn(false, animated: true)
                            
                            
                            //show the annotation...
                            myMapView.selectAnnotation(markedPointAnnotations[MarkedPoint.id], animated: true)
                            
                            //Make sure the autopan does move the map back to the current location just after the user ask to look at a saved marker.
                            boolAutoPanOnResume = false
                            
                            
                            if (settingOpenMarkerDetailsAfterSearch)
                            {
                                currentSelectedMarkedPointAnnotation = markedPointAnnotations[MarkedPoint.id]
                                
                                var i: Int = 0
                                
                                for a in markedPointAnnotations
                                {
                                    if a.title == sm
                                    {
                                        currentSelectedMarkedPointElementId = i
                                    }
                                    
                                    i = i + 1
                                }
                                
                                
                                boolGotoDetailsOnviewDidLoad = true
  
                            }
                            
                            
                        }
                    }
                    else
                    {
                        //Do Nothing
                    }
                    
                }
                
            }
        }
        
        
    }
    
    

    
    @IBAction func MarkLocationButtonTapped(_ sender: AnyObject) {
        
        //print ("MarkLocationButtonTapped")
        var tempMarkedPoint :MarkedPoint?
        
        
        //Name is index + 1 as index starts at zero
        if settingDefaultMarkerdPointName==0
        {
            tempMarkedPoint = MarkedPoint(name: "Marked Location \(markedPointAnnotations.count + 1 )", id : markedPointAnnotations.count, lat: myMapView.centerCoordinate.latitude, lng: myMapView.centerCoordinate.longitude)
            
            marklocation = myMapView.centerCoordinate
            
            //print ("Location marked at \(marklocation)")
            
            let pointAnnotation = MKPointAnnotationCustom()
            pointAnnotation.coordinate = marklocation
            pointAnnotation.title = tempMarkedPoint!.name
            pointAnnotation.userData = markedPointAnnotations.count
            
            myMapView.addAnnotation(pointAnnotation)
            
            markedPointAnnotations.append(pointAnnotation)
            MarkedPointArr.append(tempMarkedPoint!)
        }
        
        //Name is address
        if settingDefaultMarkerdPointName==1
        {
            //Reverse Geocode
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude : myMapView.centerCoordinate.latitude, longitude: myMapView.centerCoordinate.longitude)) { (placemarks, error)  in
                

                    if let placemarks = placemarks {
                        let placemark = placemarks[0]
                        var proposedName : String =  self.formatAddressFromPlacemark(placemark)
                        
                        //Check if this name has been used before...
                        
                        var i = 1
                        while (checkIfNameExisits(proposedName))
                        {
                            i = i + 1
                            proposedName =  self.formatAddressFromPlacemark(placemark) + " (" + String(i) + ")"
                        }
                        
                        tempMarkedPoint = MarkedPoint(name: proposedName, id : self.markedPointAnnotations.count, lat: self.myMapView.centerCoordinate.latitude, lng: self.myMapView.centerCoordinate.longitude)
                        
                        self.marklocation = self.myMapView.centerCoordinate
                        
                        let pointAnnotation = MKPointAnnotationCustom()
                        pointAnnotation.coordinate = self.marklocation
                        pointAnnotation.title = tempMarkedPoint!.name
                        pointAnnotation.userData = self.markedPointAnnotations.count
                        
                        self.myMapView.addAnnotation(pointAnnotation)
                        
                        self.markedPointAnnotations.append(pointAnnotation)
                        MarkedPointArr.append(tempMarkedPoint!)
                        
                    }
            }
            
            
        }
        
        //06/05/2016 - Save after a point is added
        saveData()
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print (error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currentLocation = CLLocationCoordinate2D(latitude : locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
        
        if let ha  = manager.location?.horizontalAccuracy
        {
            if boolAutoPan
            {
                let myRegion = MKCoordinateRegion.init(center: currentLocation!, latitudinalMeters: ha , longitudinalMeters: ha)
                myMapView.setRegion(myRegion, animated: true)
            }
            else
            {
                if boolAutoPanOnResume
                {
                    let myRegion = MKCoordinateRegion.init(center: currentLocation!, latitudinalMeters: ha , longitudinalMeters: ha)
                    myMapView.setRegion(myRegion, animated: true)
                    boolAutoPanOnResume = false
                }
                
            }
            if locationPointAnnotation.title != nil
            {
                myMapView.removeAnnotation(locationPointAnnotation)
            }
            
            
            //Reverse Geocode
            CLGeocoder().reverseGeocodeLocation(locations.last!) { (placemarks, error)  in
                    if let placemarks = placemarks {
                        let placemark = placemarks[0]
                        self.addressLabel.text = self.formatAddressFromPlacemark(placemark)
                        
                        //let myAddressDictionary = placemark.addressDictionary
                        
                        self.sourceMapItem = MKMapItem(placemark:  MKPlacemark(coordinate: placemark.location!.coordinate))
                        
                        //self.sourceMapItem = MKMapItem(placemark:  MKPlacemark(coordinate: placemark.location!.coordinate,
                        //addressDictionary: myAddressDictionary as! [String:AnyObject]?))
                        
                    }
            }
            
            
            statusLabel.text = "Found Your Location"

            
            Analytics.logEvent("share_image", parameters: [
            "name": "Found Location" as NSObject,
            "full_text": "Found Your Location" as NSObject
            ])
        }

    }

    func createAndLoadInterstitial() -> GADInterstitial
    {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-0604146100849518/4655687201")
        
        let request = GADRequest()
        
        //Current Location For Devide gets sent to GADRequest
        if let currentLocation = locationManager.location {
            request.setLocationWithLatitude(CGFloat(currentLocation.coordinate.latitude),longitude: CGFloat(currentLocation.coordinate.longitude),accuracy: CGFloat(currentLocation.horizontalAccuracy))
        }
        
        // Requests test ads on test devices.
        let devices: [String] = ["7fc59f853d9dbd8193c2fb6dd425c689", "e17c6fd140eeebaa9972b80f81385489", kGADSimulatorID as! String]
        //request.testDevices = devices
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = devices
        
        interstitial.load(request)
        interstitial.delegate = self
        return interstitial
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func settingsTap(_ sender: AnyObject) {
        print("Settings Tap")
    }
    
    
    @objc func applicationDidBecomeActive(_ notification: Notification)
    {
        //get the map to do one pan to current location on resume
        if settingPanToCurrentLoctionOnOpen
        {
            boolAutoPanOnResume = true
        }
        
    }
    
    
    @objc func applicationDidEnterBackground(_ notification: Notification)
    {
        saveData()
    }
    
    func saveData()
    {
        //Save data
        let myArray = NSMutableArray()
        
        var strTmp : String?
        var i : Int = 0
        
        for MarkedPoint in MarkedPointArr
        {
            //About to save CSV, so replace any commas in the name with *|*
            let newString = MarkedPoint.name.replacingOccurrences(of: ",", with: "*|*")
            //Note i re-issues IDs when saving
            strTmp = String(i) + ","  + String(MarkedPoint.lat) + "," + String(MarkedPoint.lng) + "," + newString
            print(strTmp!)
            myArray.add(strTmp!)
            i = i + 1
        }
        
        myArray.write(to: pathToFile(kFileName)!, atomically: true)
        //Save data
    }
    
    func mapView(_ MapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        userZoom = myMapView.region.span.latitudeDelta        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
       
        if (annotation === myMapView.userLocation)
        {
            //Show the user location
            return nil;
        }
        
        
        let defaultPinID = "myPinID"
        var pinView = myMapView.dequeueReusableAnnotationView(withIdentifier: defaultPinID) as! MKPinAnnotationView?
        
        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: defaultPinID)
        }
        
        
        if annotation.title! != "Your Location" && annotation.title! != "Current Location"
        {
            pinView?.pinTintColor = UIColor.red
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.isDraggable = true
            
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else
        {
            //printpinView
            pinView?.pinTintColor = UIColor.green
            pinView?.animatesDrop = false
            pinView?.annotation = annotation
            //pinView?.image = UIImage(named:"location")
        }
        
        
        return pinView!
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        print("edit marked location")
        
        if (view.annotation?.title)! != "Your Location"
        {
            currentSelectedMarkedPointAnnotation = view.annotation as! MKPointAnnotationCustom
            
            var i: Int = 0
            
            for a in markedPointAnnotations
            {
             
                if a.title == (view.annotation?.title)!
                {
                    currentSelectedMarkedPointElementId = i
                }
                
                i = i + 1
            }
            
            //run once
            if self.interstitial.isReady
            {
                self.interstitial.present(fromRootViewController: self)
            }
            else
            {
                self.performSegue(withIdentifier: "ShowPopoverFromPin", sender: self)
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay is MKPolyline
        {
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.green.withAlphaComponent(0.75)
            polylineRenderer.lineWidth = 5
            
            return polylineRenderer
        }
        else if overlay is MKCircle
        {
            let cicle = overlay as! MKCircle
            let cicleRenderer = MKCircleRenderer(circle: cicle)
            cicleRenderer.strokeColor = UIColor.red.withAlphaComponent(0.5)
            cicleRenderer.fillColor = UIColor.cyan.withAlphaComponent(0.05)
            cicleRenderer.lineWidth = 1
            return cicleRenderer
        }
        return MKPolylineRenderer()
        
    }
    
    func plotPolyline(_ route: MKRoute) {
        
        // If the polyline has been drawn previously, remove it
        if displayedPolyline != nil
        {
            myMapView.removeOverlay(displayedPolyline!)
        }
        
        displayedPolyline = route.polyline
        
        myMapView.addOverlay(displayedPolyline!)
        
        myMapView.setVisibleMapRect(route.polyline.boundingMapRect,  edgePadding: UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0), animated: true)
    }
    
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        //print ("interstitialDidDismissScreen")
        self.performSegue(withIdentifier: "ShowPopoverFromPin", sender: self)
        self.interstitial = createAndLoadInterstitial()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowSettings"
        {
            (segue.destination as! SettingsViewController).delegate = self
        }
        
        if segue.identifier == "ShowPopoverFromPin"
        {
            
            let myPopoverController = segue.destination as! PopoverContentViewController
            
            //  12/05/2020 : Comment out 3 below, add 3 below those
            //  Reason : setValue was causing an error this class is not key value coding-compliant for the key...
            
            //myPopoverController.setValue(currentSelectedMarkedPointAnnotation.title!, forKey : "originalMarkedLocationName")
            //myPopoverController.setValue(currentSelectedMarkedPointAnnotation.coordinate.latitude.description, forKey : "markedLocationLat")
            //myPopoverController.setValue(currentSelectedMarkedPointAnnotation.coordinate.longitude.description, forKey : "markedLocationLng")
            
            
               myPopoverController.originalMarkedLocationName = currentSelectedMarkedPointAnnotation.title!
               myPopoverController.markedLocationLat = currentSelectedMarkedPointAnnotation.coordinate.latitude.description
               myPopoverController.markedLocationLng = currentSelectedMarkedPointAnnotation.coordinate.longitude.description
               
               
            
            (segue.destination as! PopoverContentViewController).delegate = self
        }
        
        //showSearchDialog
        if segue.identifier == "showSearchDialog"
        {
            if let searchController = segue.destination as? SearchViewController
            {
                var myArray = [String]()
                
                for markedPoint in MarkedPointArr
                {
                    
                    myArray.append(markedPoint.name)
                }
                
                myArray.sort() { $1 > $0 } // sort the fruit by name
                
                searchController.arrMarkedLocationNames = myArray
                searchController.MarkedPointArr = MarkedPointArr
                
                searchController.delegate = self
            }
        }
        
    }
    
    func formatAddressFromPlacemark(_ placemark: CLPlacemark) -> String {
        let address = "\(placemark.subThoroughfare ?? ""), \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.subLocality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
       return (address)
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if newState == .starting
        {
            var i: Int = 0
            
            for a in markedPointAnnotations
            {
                if a.title == (view.annotation?.title)!
                {
                    currentSelectedMarkedPointElementId = i
                }
                
                i = i + 1
            }
        }
        
        if newState == .ending
        {
            MarkedPointArr[currentSelectedMarkedPointElementId!].lat = (view.annotation?.coordinate.latitude)!
            MarkedPointArr[currentSelectedMarkedPointElementId!].lng = (view.annotation?.coordinate.longitude)!
        }
    }
}

extension ViewController: MarkedLocationDelegate {
    func updateData(_ data: String) {
        
        print(currentSelectedMarkedPointElementId!)
        
        markedPointAnnotations.remove(at: currentSelectedMarkedPointElementId!)
        MarkedPointArr.remove(at: currentSelectedMarkedPointElementId!)
        
        
        let marklocation : CLLocationCoordinate2D = currentSelectedMarkedPointAnnotation.coordinate
        
        
        myMapView.removeAnnotation(currentSelectedMarkedPointAnnotation)
        
        
        let tempMarkedPoint = MarkedPoint(name: data, id : markedPointAnnotations.count ,  lat: currentSelectedMarkedPointAnnotation.coordinate.latitude, lng: currentSelectedMarkedPointAnnotation.coordinate.longitude)
        
        
        let pointAnnotation = MKPointAnnotationCustom()
        pointAnnotation.coordinate = marklocation
        pointAnnotation.title = data
        pointAnnotation.userData = markedPointAnnotations.count
        
        myMapView.addAnnotation(pointAnnotation)
        
        markedPointAnnotations.append(pointAnnotation)
        MarkedPointArr.append(tempMarkedPoint)
    }
    
    
    //deleteData from popover view
    func deleteData(_ boolDelete: Bool) {
        if boolDelete{

            //print("deleting...index = " + String(currentSelectedMarkedPointAnnotation.userData!))
            
            markedPointAnnotations.remove(at: currentSelectedMarkedPointAnnotation.userData!)
            MarkedPointArr.remove(at: currentSelectedMarkedPointAnnotation.userData! )
            myMapView.removeAnnotation(currentSelectedMarkedPointAnnotation)
            
            
            //reset ID's
            var i : Int = 0
            for _ in MarkedPointArr
            {
                MarkedPointArr[i].id = i
                i = i + 1
            }
            
            i = 0
            
            for _ in markedPointAnnotations
            {
                markedPointAnnotations[i].userData = i
                i = i + 1
            }
    
            
            saveData()
        }
    }
    
    func takeMeHere(_ TakeMeHere: MKMapItem)
    {
        print("take me here...")
        // From     currentSelectedMarkedPointAnnotation.coordinate
        // To       currentLocation!
        
        //Is there a current location known?
        
        if sourceMapItem != nil {
            calculateSegmentDirections(sourceMapItem!, destMapItem: TakeMeHere)
        }
        else
        {
            print ("Current location unknown!")
            
            
            boolShowNoLocationAlert = true
            
        }
        
    }
    
    
    func calculateSegmentDirections(_ sourceMapItem: MKMapItem, destMapItem: MKMapItem) {
        
        var time: TimeInterval = 0
        
        // 1
        let request: MKDirections.Request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = destMapItem
        // 2
        request.requestsAlternateRoutes = true
        // 3
        request.transportType = .any
        // 4
        let directions = MKDirections(request: request)
       
        directions.calculate (completionHandler: {
            (response: MKDirections.Response?, error: Error?) in
            if let routeResponse = response?.routes {
                
                let quickestRouteForSegment: MKRoute = routeResponse.sorted(by: {$0.expectedTravelTime < $1.expectedTravelTime})[0]
                
                time += quickestRouteForSegment.expectedTravelTime
                
                self.showRoute(routeResponse, time: time)

                
            }
        } )
    }
    
    
    func showRoute(_ routes: [MKRoute], time: TimeInterval) {
        //var directionsArray = [(startingAddress: String, endingAddress: String, route: MKRoute)]()
        
        for i in 0..<routes.count {
            plotPolyline(routes[i])
            //directionsArray += [(locationArray[i].textField.text!, locationArray[i+1].textField.text!, routes[i])]
        }
        
        //displayDirections(directionsArray)
        printTimeToLabel(time)
    }
    
    func printTimeToLabel(_ time: TimeInterval) {
        let timeString = time.formatted()
        //totalTimeLabel.text = "Total Time: \(timeString)"
        
        print ("Total Time: \(timeString)")
    }
}

extension ViewController: SearchDelegate {
    func deleteMarker(_ data: String) {
        
        
        var i: Int = 0
        
        for a in markedPointAnnotations
        {
            
            if a.title == data
            {
                currentSelectedMarkedPointElementId = i
            }
            
            i = i + 1
        }
        
        currentSelectedMarkedPointAnnotation = markedPointAnnotations[currentSelectedMarkedPointElementId!]
        
        print("deleting...index = " + String(currentSelectedMarkedPointAnnotation.userData!))
        
        markedPointAnnotations.remove(at: currentSelectedMarkedPointAnnotation.userData!)
        MarkedPointArr.remove(at: currentSelectedMarkedPointAnnotation.userData! )
        myMapView.removeAnnotation(currentSelectedMarkedPointAnnotation)
        
        //reset i back to zero
        i = 0
        
        //reset ID's
        
        for _ in MarkedPointArr
        {
            MarkedPointArr[i].id = i
            i = i + 1
        }
        
        i = 0
        
        for _ in markedPointAnnotations
        {
            markedPointAnnotations[i].userData = i
            i = i + 1
        }
        
        //06/05/2016 - Save after a point is deleted
        saveData()
    }
}

extension ViewController: SettingsDelegate {
    
    func updateDefaultMarkerName(_ data: Int) {
        if data == 0 {
            settingDefaultMarkerdPointName = 0
        }
        else {
            settingDefaultMarkerdPointName = 1
        }
        
    }
    
    func updateSettingPanToCurrentLocationOnOpen(_ data: Bool) {
        if data == false{
            settingPanToCurrentLoctionOnOpen = false
        }
        else {
            settingPanToCurrentLoctionOnOpen = true
        }
    }
    
    func updateSettingOpenMarkerDetailsAfterSearch(_ data: Bool) {
        if data == false{
            settingOpenMarkerDetailsAfterSearch = false
        }
        else {
            settingOpenMarkerDetailsAfterSearch = true
        }
    }
    
    func updateSettingShowCompass(_ data: Bool) {
        if data == false{
            settingShowCompass = false
            myMapView.showsCompass = false
        }
        else {
            settingShowCompass = true
            myMapView.showsCompass = true
        }
    }
    
    func updateSettingShowTraffic(_ data: Bool) {
        if data == false{
            settingShowTraffic = false
            myMapView.showsTraffic = false
        }
        else {
            settingShowTraffic = true
            myMapView.showsTraffic = true
        }
    }
    
    func updateSettingShowScale(_ data: Bool) {
        if data == false{
            settingShowScale = false
            myMapView.showsScale = false
        }
        else {
            settingShowScale = true
            myMapView.showsScale = true
        }
    }
    
    func updateSettingMapType(_ data: Int) {
        if data == 0 {
            settingMapType = "Standard"
            myMapView.mapType = MKMapType.standard
        }
        if data == 1 {
            settingMapType = "Satellite"
            myMapView.mapType = MKMapType.satellite
        }
        if data == 2 {
            settingMapType = "Hybrid"
            myMapView.mapType = MKMapType.hybrid
        }
    }
    
    func updateSettingDeleteAllUserData(_ data: Bool) {
        if data == true{
            
            let annotationsToRemove = myMapView.annotations.filter { $0 !== myMapView.userLocation }
            myMapView.removeAnnotations( annotationsToRemove )
            
            // If the polyline has been drawn previously, remove it
            if displayedPolyline != nil
            {
                myMapView.removeOverlay(displayedPolyline!)
            }
            
        }
        
    }
    
    func loadSettings() {
        // getting path to file kSettingsFileName
        
        let path = pathToFile(kSettingsFileName)
        let fileManager = FileManager.default
        //check if file exists
        if !(FileManager.default.fileExists(atPath: pathToFile(kSettingsFileName)!.path))
        {
            // If it doesn't, copy it from the default file in the Bundle
            
            if let bundlePath = Bundle.main.path(forResource: defaultSettingsfileName, ofType: "plist") {
                
                //let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                //print("\(defaultSettingsfileName) file is --> \(resultDictionary?.description)")
                
                do{
                    
                    try
                        fileManager.copyItem(atPath: bundlePath, toPath: (path?.path)!)
                    
                    //print("copy")
                    
                }
                catch let error as NSError
                {
                    print("error : \(error)")
                }
                
                
                
                
            } else {
                print("\(defaultSettingsfileName).plist  not found. Please, make sure it is part of the bundle.")
            }
        } else {
            //print("File already exits at path.")
        }
        
        
        //let resultDictionary = NSMutableDictionary(contentsOfFile: path!.path!)
        //print("Loaded \(kSettingsFileName) file is --> \(resultDictionary?.description)")
        
        let myDict = NSDictionary(contentsOfFile: path!.path)
        
        
        if let dict = myDict {

            if let tmpsettingDefaultMarkerdPointName = dict.object(forKey: "DefaultMarkerdPointName") as? Int
            {
                settingDefaultMarkerdPointName = tmpsettingDefaultMarkerdPointName
            }
            if let tmpsettingPanToCurrentLoctionOnOpen = dict.object(forKey: "PanToCurrentLoctionOnOpen") as? Bool
            {
                settingPanToCurrentLoctionOnOpen = tmpsettingPanToCurrentLoctionOnOpen
            }
            if let tmpsettingOpenMarkerDetailsAfterSearch = dict.object(forKey: "OpenMarkerDetailsAfterSearch") as? Bool
            {
                settingOpenMarkerDetailsAfterSearch = tmpsettingOpenMarkerDetailsAfterSearch
            }
            if let tmpsettingShowCompass = dict.object(forKey: "ShowCompass") as? Bool
            {
                settingShowCompass = tmpsettingShowCompass
            }
            if let tmpsettingShowScale = dict.object(forKey: "ShowScale") as? Bool
            {
                settingShowScale = tmpsettingShowScale
            }
            if let tmpsettingShowTraffic = dict.object(forKey: "ShowTraffic") as? Bool
            {
                settingShowTraffic = tmpsettingShowTraffic
            }
            if let tmpsettingMapType = dict.object(forKey: "MapType") as? String
            {
                settingMapType = tmpsettingMapType
            }
            //...
        } else {
            print("WARNING: Couldn't create dictionary from \(kSettingsFileName) Default values will be used!")
        }
 
        
    }
    
    
    func saveSettings()
    {
        //let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        
        let path = pathToFile(kSettingsFileName)
        let dict: NSMutableDictionary = ["XInitializerItem": "DoNotEverChangeMe"]
        //saving values
        dict.setObject(settingDefaultMarkerdPointName, forKey: "DefaultMarkerdPointName" as NSCopying)
        dict.setObject(settingPanToCurrentLoctionOnOpen, forKey: "PanToCurrentLoctionOnOpen" as NSCopying)
        dict.setObject(settingOpenMarkerDetailsAfterSearch, forKey: "OpenMarkerDetailsAfterSearch" as NSCopying)
        dict.setObject(settingShowCompass, forKey: "ShowCompass" as NSCopying)
        dict.setObject(settingShowTraffic, forKey: "ShowTraffic" as NSCopying)
        dict.setObject(settingShowScale, forKey: "ShowScale" as NSCopying)
        dict.setObject(settingMapType, forKey: "MapType" as NSCopying)
        //...
        //writing to plist
        dict.write(toFile: path!.path, atomically: false)
        
        //let resultDictionary = NSMutableDictionary(contentsOfFile: path!.path!)
        //print("Saved  \(kSettingsFileName).plist file is --> \(resultDictionary?.description)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        

        
    }
}


extension TimeInterval {
    func formatted() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second]
        
        return formatter.string(from: self)!
    }
}

func pathToFile(_ strFileName: String) -> URL?
{
    let fm = FileManager.default
    if let docsURL = try? fm.url(for: .documentDirectory, in: .userDomainMask , appropriateFor: nil, create: false) {
        return docsURL.appendingPathComponent(strFileName)
    }
    return nil
}


func checkIfNameExisits (_ name: String) -> Bool
{
    for MarkedPoint in MarkedPointArr
    {
        //Does the selected name exist?
        if  MarkedPoint.name == name
        {
            return true
        }
    }
    return false
    
}
