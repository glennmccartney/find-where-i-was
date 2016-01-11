//
//  ViewController.swift
//  Where Was I
//
//  Created by Glenn McCartney on 17/11/2015.
//  Copyright © 2015 Glenn McCartney. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


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


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
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
    
    var locationTuples: [(textField: UITextField!, mapItem: MKMapItem?)]!
    
    var currentLocation : CLLocationCoordinate2D?
    
    var sourceMapItem : MKMapItem?
    
    var displayedPolyline : MKOverlay?
    
   
    
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var autoPan: UISwitch!
    
    
    @IBAction func settingsTap(sender: AnyObject) {
        print("Settings Tap")
    }
    
    @IBAction func toggleAutoPan(sender: AnyObject) {
        boolAutoPan = !boolAutoPan
    }
    
    @IBAction func returned(segue: UIStoryboardSegue)
    {
        if ((boolShowNoLocationAlert) != nil)
        {
            let myAlert = UIAlertController(title: "My Alert", message: "Your Current Loction is Unknown", preferredStyle:UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style:.Default, handler: {(alert:
                UIAlertAction!) in
                print("OK button was pressed")
            })
            myAlert.addAction(ok)
            
            presentViewController(myAlert, animated: true, completion: nil)
        }

        if segue.identifier == "unwindSearchIdentifier"
        {
            if let searchController = segue.sourceViewController as? SearchViewController
            {
                //print (searchController.selectedMark)
                
                
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
                    
                    //reset vaule back to false
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
                            
                            let myRegion = MKCoordinateRegionMakeWithDistance(currentLocation!, (locationManager.location?.horizontalAccuracy)!, (locationManager.location?.horizontalAccuracy)!)
                            
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
                                    //print (a.title)
                                    //print (view.annotation?.title)
                                    
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
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //if the condition to open the details view has been set
        if boolGotoDetailsOnviewDidLoad == true
        {
            //reset it first...
            boolGotoDetailsOnviewDidLoad = false
            //Go
            self.performSegueWithIdentifier("ShowPopoverFromPin", sender: self)
        }
        
        
    }
    
    @IBAction func MarkLocationButtonTapped(sender: AnyObject) {
        
        print ("MarkLocationButtonTapped")
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
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude : myMapView.centerCoordinate.latitude, longitude: myMapView.centerCoordinate.longitude),
                completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
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
            })
            
            
        }
        
        
        
        
    }
    

    
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
            myMapView.mapType = MKMapType.Standard
        }
        if settingMapType == "Hybrid"
        {
            myMapView.mapType = MKMapType.Hybrid
        }
        if settingMapType == "Satellite"
        {
            myMapView.mapType = MKMapType.Satellite
        }
      
        
        if NSFileManager.defaultManager().fileExistsAtPath(pathToFile(kFileName)!.path!)
        {
            
            let myArray = NSArray(contentsOfURL: pathToFile(kFileName)!) as! [String]
            
            
            print ("Loading data...")
            
            
            for element in myArray {
                
                print("\(element) ")
                
                let fullArr = element.componentsSeparatedByString(",")
                let myDoubleLat = Double(fullArr[1])
                let myDoubleLng = Double(fullArr[2])
                
                //Commas have been saved as *|* so swap them back
                let newStringTitle = fullArr[3].stringByReplacingOccurrencesOfString("*|*", withString: ",")
                
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name:UIApplicationDidEnterBackgroundNotification, object:UIApplication.sharedApplication())
        //applicationDidBecomeActive
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidBecomeActive:", name:UIApplicationDidBecomeActiveNotification, object:UIApplication.sharedApplication())
        
        locationManager.delegate = self
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        //NSLocationWhenInUseUsageDescription
        
        if CLLocationManager.locationServicesEnabled() {
            
            
            //locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            
            statusLabel.text = "Searching For Your Location..."
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    func applicationDidBecomeActive(notification: NSNotification)
    {
        //get the map to do one pan to current location on resume
        if settingPanToCurrentLoctionOnOpen
        {
           boolAutoPanOnResume = true
        }
        
    }
    
    
    func applicationDidEnterBackground(notification: NSNotification)
    {
        //Save data
        let myArray = NSMutableArray()
        
        var strTmp : String?
        var i : Int = 0
        
        print ("Saving Data...")
        
        for MarkedPoint in MarkedPointArr
        {
            //About to save CSV, so replace any commas in the name with *|*
            let newString = MarkedPoint.name.stringByReplacingOccurrencesOfString(",", withString: "*|*")
            //Note i re-issues IDs when saving
            strTmp = String(i) + ","  + String(MarkedPoint.lat) + "," + String(MarkedPoint.lng) + "," + newString
            print(strTmp)
            myArray.addObject(strTmp!)
            i = i + 1
            
        }
        
        
        myArray.writeToURL(pathToFile(kFileName)!, atomically: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print (error.description)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        currentLocation = CLLocationCoordinate2D(latitude : locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
        
        
        if let ha  = manager.location?.horizontalAccuracy
        {
            
            if boolAutoPan
            {
                let myRegion = MKCoordinateRegionMakeWithDistance(currentLocation!, ha , ha)
                
                myMapView.setRegion(myRegion, animated: true)
            }
            else
            {
                if boolAutoPanOnResume
                {
                    let myRegion = MKCoordinateRegionMakeWithDistance(currentLocation!, ha , ha)
                    
                    myMapView.setRegion(myRegion, animated: true)
                    
                    boolAutoPanOnResume = false
                }
                
            }
            if locationPointAnnotation.title != nil
            {
                myMapView.removeAnnotation(locationPointAnnotation)
            }
            
            //locationPointAnnotation.coordinate = currentLocation!
            //locationPointAnnotation.title = "Your Location"
            //myMapView.addAnnotation(locationPointAnnotation)
            
            
            //MKCircle
            if circle != nil
            {
                myMapView.removeOverlay(circle!)
            }
            circle = MKCircle(centerCoordinate: currentLocation!, radius: 10)
            myMapView.addOverlay(circle!)
            
            
            //Reverse Geocode
            CLGeocoder().reverseGeocodeLocation(locations.last!,
                completionHandler: {(placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                    if let placemarks = placemarks {
                        let placemark = placemarks[0]
                        self.addressLabel.text = self.formatAddressFromPlacemark(placemark)
                        
                        self.sourceMapItem = MKMapItem(placemark:  MKPlacemark(coordinate: placemark.location!.coordinate,
                            addressDictionary: placemark.addressDictionary as! [String:AnyObject]?))
                    }
            })
            
            
            
            statusLabel.text = "Found Your Location"
            //locationManager.stopUpdatingLocation()
            
        }
        
        
    }
    
    func mapView(MapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        
        //print ("regionDidChangeAnimated")
        
        userZoom = myMapView.region.span.latitudeDelta
        
        //print (userZoom)
        
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        let defaultPinID = "myPinID"
        //var pinView = myMapView.dequeueReusableAnnotationViewWithIdentifier(defaultPinID)?
        var pinView = myMapView.dequeueReusableAnnotationViewWithIdentifier(defaultPinID) as! MKPinAnnotationView?
        
        if pinView == nil
        {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: defaultPinID)
        }
        
        if annotation.title! != "Your Location" && annotation.title! != "Current Location"
        {
            
            //print ("pinView?.annotation?.title = " + ((pinView?.annotation?.title)!)!)
            pinView?.pinTintColor = UIColor.redColor()
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.draggable = true
            
            
            
            //pinView?.leftCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            pinView?.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            //pinView?.detailCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
        }
        else
        {
            //printpinView
            pinView?.pinTintColor = UIColor.greenColor()
            pinView?.animatesDrop = false
            pinView?.annotation = annotation
            //pinView?.image = UIImage(named:"location")
        }
        
        
        return pinView!
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        print("edit marked location")
        
        if (view.annotation?.title)! != "Your Location"
        {
            currentSelectedMarkedPointAnnotation = view.annotation as! MKPointAnnotationCustom
            
            var i: Int = 0
            
            for a in markedPointAnnotations
            {
                print (a.title)
                print (view.annotation?.title)

                if a.title == (view.annotation?.title)!
                {
                   currentSelectedMarkedPointElementId = i
                }
                
                i = i + 1
            }
            
            
            self.performSegueWithIdentifier("ShowPopoverFromPin", sender: self)
        }
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay is MKPolyline
        {
            
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.greenColor().colorWithAlphaComponent(0.75)
            polylineRenderer.lineWidth = 5
            
            return polylineRenderer
        }
        else if overlay is MKCircle
        {
            let cicle = overlay as! MKCircle
            let cicleRenderer = MKCircleRenderer(circle: cicle)
            cicleRenderer.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.5)
            cicleRenderer.fillColor = UIColor.cyanColor().colorWithAlphaComponent(0.05)
            cicleRenderer.lineWidth = 1
            return cicleRenderer
        }
        return MKPolylineRenderer()
        
    }
    
    func plotPolyline(route: MKRoute) {
        
        // If the polyline has been drawn previously, remove it
        if displayedPolyline != nil
        {
            myMapView.removeOverlay(displayedPolyline!)
        }
        
        displayedPolyline = route.polyline
        
        myMapView.addOverlay(displayedPolyline!)
        
        myMapView.setVisibleMapRect(route.polyline.boundingMapRect,  edgePadding: UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0), animated: true)
        
    }
    

    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowSettings"
        {      
           
            (segue.destinationViewController as! SettingsViewController).delegate = self
            
        }
        
        if segue.identifier == "ShowPopoverFromPin"
        {
            
            let myPopoverController = segue.destinationViewController
            
            myPopoverController.setValue(currentSelectedMarkedPointAnnotation.title!, forKey : "originalMarkedLocationName")
            
            myPopoverController.setValue(currentSelectedMarkedPointAnnotation.coordinate.latitude.description, forKey : "markedLocationLat")
            
            myPopoverController.setValue(currentSelectedMarkedPointAnnotation.coordinate.longitude.description, forKey : "markedLocationLng")
            
            (segue.destinationViewController as! PopoverContentViewController).delegate = self
            
        }
                
        
        //showSearchDialog
        if segue.identifier == "showSearchDialog"
        {
            if let searchController = segue.destinationViewController as? SearchViewController
            {
                
                var myArray = [String]()
                
                for markedPoint in MarkedPointArr
                {
                    
                    myArray.append(markedPoint.name)
                }
                
                myArray.sortInPlace() { $1 > $0 } // sort the fruit by name
                
                searchController.arrMarkedLocationNames = myArray
                searchController.MarkedPointArr = MarkedPointArr
                
                searchController.delegate = self
            }
        }
        
        
        
    }
    
    func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as! [String]).joinWithSeparator(", ")
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        if newState == .Starting
        {
            //print ("Start drag")
            
            var i: Int = 0
            
            for a in markedPointAnnotations
            {
                //print (a.title)
                //print (view.annotation?.title)
                
                if a.title == (view.annotation?.title)!
                {
                    currentSelectedMarkedPointElementId = i
                }
                
                i = i + 1
            }

        }
        
        if newState == .Ending
        {
            //print ("End drag")
            
            MarkedPointArr[currentSelectedMarkedPointElementId!].lat = (view.annotation?.coordinate.latitude)!
            MarkedPointArr[currentSelectedMarkedPointElementId!].lng = (view.annotation?.coordinate.longitude)!
            
        }
    }
    
}



extension ViewController: MarkedLocationDelegate {
    func updateData(data: String) {
        
        
        print(currentSelectedMarkedPointElementId)
        
        markedPointAnnotations.removeAtIndex(currentSelectedMarkedPointElementId!)
        MarkedPointArr.removeAtIndex(currentSelectedMarkedPointElementId!)
        
        
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
    
    
    
    func deleteData(boolDelete: Bool) {
        if boolDelete{
            
                       
            print("deleting...index = " + String(currentSelectedMarkedPointAnnotation.userData!))
            
            markedPointAnnotations.removeAtIndex(currentSelectedMarkedPointAnnotation.userData!)
            MarkedPointArr.removeAtIndex(currentSelectedMarkedPointAnnotation.userData! )
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
            

            
        }
    }
    
    func takeMeHere(TakeMeHere: MKMapItem)
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
    
    
    func calculateSegmentDirections(sourceMapItem: MKMapItem, destMapItem: MKMapItem) {
        
        var time: NSTimeInterval = 0
        
        // 1
        let request: MKDirectionsRequest = MKDirectionsRequest()
        request.source = sourceMapItem
        request.destination = destMapItem
        // 2
        request.requestsAlternateRoutes = true
        // 3
        request.transportType = .Any
        // 4
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler ({
            (response: MKDirectionsResponse?, error: NSError?) in
            if let routeResponse = response?.routes {
                
                let quickestRouteForSegment: MKRoute = routeResponse.sort({$0.expectedTravelTime < $1.expectedTravelTime})[0]
                
                time += quickestRouteForSegment.expectedTravelTime
                
                self.showRoute(routeResponse, time: time)
                
                
                
            } else if let _ = error {
                
            }
        })
    }
    
    
    func showRoute(routes: [MKRoute], time: NSTimeInterval) {
        //var directionsArray = [(startingAddress: String, endingAddress: String, route: MKRoute)]()
        
        for i in 0..<routes.count {
            plotPolyline(routes[i])
            //directionsArray += [(locationArray[i].textField.text!, locationArray[i+1].textField.text!, routes[i])]
        }
        
        //displayDirections(directionsArray)
        printTimeToLabel(time)
    }
    
    func printTimeToLabel(time: NSTimeInterval) {
        let timeString = time.formatted()
        //totalTimeLabel.text = "Total Time: \(timeString)"
        
        
        print ("Total Time: \(timeString)")
    }
    
    
    
    
}

extension ViewController: SearchDelegate {
    func deleteMarker(data: String) {
       
 
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
        
        markedPointAnnotations.removeAtIndex(currentSelectedMarkedPointAnnotation.userData!)
        MarkedPointArr.removeAtIndex(currentSelectedMarkedPointAnnotation.userData! )
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
            
        
    }

}

extension ViewController: SettingsDelegate {
    
    func updateDefaultMarkerName(data: Int) {
        if data == 0 {      
            settingDefaultMarkerdPointName = 0
        }
        else {
            settingDefaultMarkerdPointName = 1
        }
   
    }
    
    func updateSettingPanToCurrentLocationOnOpen(data: Bool) {
        if data == false{
            settingPanToCurrentLoctionOnOpen = false
        }
        else {
            settingPanToCurrentLoctionOnOpen = true
        }
    }
    
    func updateSettingOpenMarkerDetailsAfterSearch(data: Bool) {
        if data == false{
            settingOpenMarkerDetailsAfterSearch = false
        }
        else {
            settingOpenMarkerDetailsAfterSearch = true
        }
    }
    
    func updateSettingShowCompass(data: Bool) {
        if data == false{
            settingShowCompass = false
            myMapView.showsCompass = false
        }
        else {
            settingShowCompass = true
            myMapView.showsCompass = true
        }
    }
    
    func updateSettingShowTraffic(data: Bool) {
        if data == false{
            settingShowTraffic = false
            myMapView.showsTraffic = false
        }
        else {
            settingShowTraffic = true
            myMapView.showsTraffic = true
        }
    }
    
    func updateSettingShowScale(data: Bool) {
        if data == false{
            settingShowScale = false
            myMapView.showsScale = false
        }
        else {
            settingShowScale = true
            myMapView.showsScale = true
        }
    }
    
    func updateSettingMapType(data: Int) {
        if data == 0 {
            settingMapType = "Standard"
            myMapView.mapType = MKMapType.Standard
        }
        if data == 1 {
            settingMapType = "Satellite"
            myMapView.mapType = MKMapType.Satellite
        }
        if data == 2 {
            settingMapType = "Hybrid"
            myMapView.mapType = MKMapType.Hybrid
        }
    }
    
    func updateSettingDeleteAllUserData(data: Bool) {
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
        //let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray
        //let documentsDirectory = paths[0] as! String
        let path = pathToFile(kSettingsFileName)
        let fileManager = NSFileManager.defaultManager()
        //check if file exists
        if !(NSFileManager.defaultManager().fileExistsAtPath(pathToFile(kSettingsFileName)!.path!))
        {
            // If it doesn't, copy it from the default file in the Bundle
           
            if let bundlePath = NSBundle.mainBundle().pathForResource(defaultSettingsfileName, ofType: "plist") {
                
                let resultDictionary = NSMutableDictionary(contentsOfFile: bundlePath)
                
                print("\(defaultSettingsfileName) file is --> \(resultDictionary?.description)")
                
                do{
                try
                    fileManager.copyItemAtPath(bundlePath, toPath: (path?.path)!)
                    
                    print("copy")
                    
                }
                catch let error as NSError
                    {
                        print("error : \(error)")
                }
            
                
                
                
            } else {
                print("\(defaultSettingsfileName).plist  not found. Please, make sure it is part of the bundle.")
            }
        } else {
            print("File already exits at path.")
            // use this to delete file from documents directory
            //fileManager.removeItemAtPath(path, error: nil)
        }
        
        
        let resultDictionary = NSMutableDictionary(contentsOfFile: path!.path!)
        
        print("Loaded \(kSettingsFileName) file is --> \(resultDictionary?.description)")
        
        let myDict = NSDictionary(contentsOfFile: path!.path!)
    
            
            if let dict = myDict {
                //loading values
                
                
                
                if let tmpsettingDefaultMarkerdPointName = dict.objectForKey("DefaultMarkerdPointName") as? Int
                {
                   settingDefaultMarkerdPointName = tmpsettingDefaultMarkerdPointName
                }
                if let tmpsettingPanToCurrentLoctionOnOpen = dict.objectForKey("PanToCurrentLoctionOnOpen") as? Bool
                {
                    settingPanToCurrentLoctionOnOpen = tmpsettingPanToCurrentLoctionOnOpen
                }
                if let tmpsettingOpenMarkerDetailsAfterSearch = dict.objectForKey("OpenMarkerDetailsAfterSearch") as? Bool
                {
                    settingOpenMarkerDetailsAfterSearch = tmpsettingOpenMarkerDetailsAfterSearch
                }
                if let tmpsettingShowCompass = dict.objectForKey("ShowCompass") as? Bool
                {
                    settingShowCompass = tmpsettingShowCompass
                }
                if let tmpsettingShowScale = dict.objectForKey("ShowScale") as? Bool
                {
                    settingShowScale = tmpsettingShowScale
                }
                if let tmpsettingShowTraffic = dict.objectForKey("ShowTraffic") as? Bool
                {
                    settingShowTraffic = tmpsettingShowTraffic
                }
                if let tmpsettingMapType = dict.objectForKey("MapType") as? String
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
        dict.setObject(settingDefaultMarkerdPointName, forKey: "DefaultMarkerdPointName")
        dict.setObject(settingPanToCurrentLoctionOnOpen, forKey: "PanToCurrentLoctionOnOpen")
        dict.setObject(settingOpenMarkerDetailsAfterSearch, forKey: "OpenMarkerDetailsAfterSearch")
        dict.setObject(settingShowCompass, forKey: "ShowCompass")
        dict.setObject(settingShowTraffic, forKey: "ShowTraffic")
        dict.setObject(settingShowScale, forKey: "ShowScale")
        dict.setObject(settingMapType, forKey: "MapType")
        //...
        //writing to plist
        dict.writeToFile(path!.path!, atomically: false)
        let resultDictionary = NSMutableDictionary(contentsOfFile: path!.path!)
        print("Saved  \(kSettingsFileName).plist file is --> \(resultDictionary?.description)")
        
    }
    

}


extension NSTimeInterval {
    func formatted() -> String {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Full
        formatter.allowedUnits = [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        
        return formatter.stringFromTimeInterval(self)!
    }
}

func pathToFile(strFileName: String) -> NSURL?
{
    let fm = NSFileManager.defaultManager()
    if let docsURL = try? fm.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask , appropriateForURL: nil, create: false) {
        return docsURL.URLByAppendingPathComponent(strFileName)
    }
    return nil
}


func checkIfNameExisits (name: String) -> Bool
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
