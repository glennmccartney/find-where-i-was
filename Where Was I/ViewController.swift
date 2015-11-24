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

var MarkedPointArr = [] as [MarkedPoint]



class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
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
    
    let kFileName = "savedData.plist"
    
    
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
        print("Segue Unwound")
        
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
            
            print ("unwindSearchIdentifier")
            
            if let searchController = segue.sourceViewController as? SearchTableViewController
            {
                
                print (searchController.selectedMark)
                
                for MarkedPoint in MarkedPointArr
                {
                    
                    if MarkedPoint.name  == searchController.selectedMark!
                    {
                    
                        currentLocation = CLLocationCoordinate2D(latitude : MarkedPoint.lat, longitude: MarkedPoint.lng)
                        
                        let myRegion = MKCoordinateRegionMakeWithDistance(currentLocation!, (locationManager.location?.horizontalAccuracy)!, (locationManager.location?.horizontalAccuracy)!)
                                
                        myMapView.setRegion(myRegion, animated: true)

                        boolAutoPan = false
                        autoPan.setOn(false, animated: true)
                        
                    }
                    
                    
                    
                }

               
            }
        }
        
        
    }
    
    @IBAction func MarkLocationButtonTapped(sender: AnyObject) {
        
        print ("MarkLocationButtonTapped")
        
        
        //Name is index + 1 as index strats at zero
        let tempMarkedPoint = MarkedPoint(name: "Marked Location \(markedPointAnnotations.count + 1 )", id : markedPointAnnotations.count, lat: myMapView.centerCoordinate.latitude, lng: myMapView.centerCoordinate.longitude)
        
        marklocation = myMapView.centerCoordinate
        
        print ("Location marked at \(marklocation)")
        
        let pointAnnotation = MKPointAnnotationCustom()
        pointAnnotation.coordinate = marklocation
        pointAnnotation.title = tempMarkedPoint.name
        pointAnnotation.userData = markedPointAnnotations.count
        
        myMapView.addAnnotation(pointAnnotation)
        
        markedPointAnnotations.append(pointAnnotation)
        MarkedPointArr.append(tempMarkedPoint)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if NSFileManager.defaultManager().fileExistsAtPath(pathToFile()!.path!)
        {
            
            let myArray = NSArray(contentsOfURL: pathToFile()!) as! [String]
            
            
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
    
    
    func pathToFile() -> NSURL?
    {
        let fm = NSFileManager.defaultManager()
        if let docsURL = try? fm.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask , appropriateForURL: nil, create: false) {
            return docsURL.URLByAppendingPathComponent(kFileName)
        }
        return nil
    }
    
    func applicationDidEnterBackground(notification: NSNotification)
    {
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
        
        
        myArray.writeToURL(pathToFile()!, atomically: true)
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
            
            if locationPointAnnotation.title != nil
            {
                myMapView.removeAnnotation(locationPointAnnotation)
            }
            
            locationPointAnnotation.coordinate = currentLocation!
            locationPointAnnotation.title = "Your Location"
            
            myMapView.addAnnotation(locationPointAnnotation)
            
            
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
        
        if annotation.title! != "Your Location"
        {
            print (pinView?.annotation?.title)
            pinView?.pinTintColor = UIColor.greenColor()
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
            pinView?.pinTintColor = UIColor.redColor()
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
                //print (a.title)
                //print (view.annotation?.title)

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
            
            /*
            let route = overlay as! MKPolyline
            let routeRenderer = MKPolylineRenderer(polyline: route)
            routeRenderer.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.6)
            let pattern = [2, 5]
            routeRenderer.lineDashPattern = pattern
            routeRenderer.lineWidth = 3
            */
            
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
        if segue.identifier == "ShowPopoverFromPin"
        {
            
            let myPopoverController = segue.destinationViewController
            
            myPopoverController.setValue(currentSelectedMarkedPointAnnotation.title!, forKey : "originalMarkedLocationName")
            
            myPopoverController.setValue(currentSelectedMarkedPointAnnotation.coordinate.latitude.description, forKey : "markedLocationLat")
            
            myPopoverController.setValue(currentSelectedMarkedPointAnnotation.coordinate.longitude.description, forKey : "markedLocationLng")
            
            (segue.destinationViewController as! PopoverContentViewController).delegate = self
            
        }
        
        if segue.identifier == "showSearch"
        {
            if let searchController = segue.destinationViewController as? SearchTableViewController
            {
                
                var myArray = [String]()
   
                for markedPoint in MarkedPointArr
                {
                    
                    myArray.append(markedPoint.name)
                }
                
                myArray.sortInPlace() { $1 > $0 } // sort the fruit by name
                
                searchController.arrMarkedLocationNames = myArray
                searchController.MarkedPointArr = MarkedPointArr
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
        
        //self.internalData = data
        
        //var idtoremove : Int = currentSelectedMarkedPointAnnotation.userData!
        //currentSelectedMarkedPointElementId
        
        print(currentSelectedMarkedPointElementId)
        
        markedPointAnnotations.removeAtIndex(currentSelectedMarkedPointElementId!)
        MarkedPointArr.removeAtIndex(currentSelectedMarkedPointElementId!)
        
        //markedPointAnnotations.removeAtIndex(currentSelectedMarkedPointAnnotation.userData! - 1)
        //MarkedPointArr.removeAtIndex(currentSelectedMarkedPointAnnotation.userData! - 1)

        
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
            
            print("deleting...")
            markedPointAnnotations.removeAtIndex(currentSelectedMarkedPointAnnotation.userData!)
            MarkedPointArr.removeAtIndex(currentSelectedMarkedPointAnnotation.userData! )
            myMapView.removeAnnotation(currentSelectedMarkedPointAnnotation)
            
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
        request.transportType = .Walking
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

extension NSTimeInterval {
    func formatted() -> String {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Full
        formatter.allowedUnits = [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        
        return formatter.stringFromTimeInterval(self)!
    }
}

