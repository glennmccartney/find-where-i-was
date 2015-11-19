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


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var marklocation = CLLocationCoordinate2D()
    var locationPointAnnotation = MKPointAnnotation()
    var userZoom : Double = 0
    var circle : MKCircle?
    
    var markedPointAnnotations = [MKPointAnnotationCustom()]
    var currentSelectedMarkedPointAnnotation = MKPointAnnotationCustom()
   
    var locationTuples: [(textField: UITextField!, mapItem: MKMapItem?)]!
    
    var currentLocation : CLLocationCoordinate2D?
    
    var sourceMapItem : MKMapItem?
    
    var displayedPolyline : MKOverlay?
    
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    @IBAction func returned(segue: UIStoryboardSegue)
    {
        print("Segue Unwound")
        
    }
    
    @IBAction func MarkLocationButtonTapped(sender: AnyObject) {
        
        print ("MarkLocationButtonTapped")
        
        //myMapView.centerCoordinate
        //locationManager.location?.coordinate
        
        
        marklocation = myMapView.centerCoordinate
        
        print ("Location marked at \(marklocation)")
        
        let pointAnnotation = MKPointAnnotationCustom()
        pointAnnotation.coordinate = marklocation
        pointAnnotation.title = "Marked Location \(markedPointAnnotations.count )"
        pointAnnotation.userData = markedPointAnnotations.count
            
        myMapView.addAnnotation(pointAnnotation)
            
        markedPointAnnotations.append(pointAnnotation)
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
    
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        currentLocation = CLLocationCoordinate2D(latitude : locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
        
        
        if let ha  = manager.location?.horizontalAccuracy
        {
            
            let myRegion = MKCoordinateRegionMakeWithDistance(currentLocation!, ha , ha)
            
            myMapView.setRegion(myRegion, animated: true)
            
  
            if locationPointAnnotation.title != nil
            {
                myMapView.removeAnnotation(locationPointAnnotation)
            }
            
            locationPointAnnotation.coordinate = currentLocation!
            locationPointAnnotation.title = "Your Location"
           
            myMapView.addAnnotation(locationPointAnnotation)
            
     
            
           
            
            //MKCircle
            
            if circle?.coordinate != nil
            {
                myMapView.removeAnnotation(circle!)
            }
            circle = MKCircle(centerCoordinate: currentLocation!, radius: 10)
            //myMapView.addOverlay(circle!)
            
            
            
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
            locationManager.stopUpdatingLocation()
            
        }
        
        
    }
    
    func mapView(MapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        
        //print ("regionDidChangeAnimated")
        
        userZoom = myMapView.region.span.latitudeDelta
        
        print (userZoom)
        
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
            pinView?.annotation = annotation
            //pinView?.image = UIImage(named:"location")
        }
        
        
        return pinView!
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        print("edit marked location")
        
        currentSelectedMarkedPointAnnotation = view.annotation as! MKPointAnnotationCustom
        self.performSegueWithIdentifier("ShowPopoverFromPin", sender: self)
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
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print (error.description)
        
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
    }
    
    func formatAddressFromPlacemark(placemark: CLPlacemark) -> String {
        return (placemark.addressDictionary!["FormattedAddressLines"] as! [String]).joinWithSeparator(", ")
    }
    
}

extension ViewController: MarkedLocationDelegate {
        func updateData(data: String) {
            
            //self.internalData = data
            markedPointAnnotations.removeAtIndex(currentSelectedMarkedPointAnnotation.userData! - 1)
            
            let marklocation : CLLocationCoordinate2D = currentSelectedMarkedPointAnnotation.coordinate
            
            
            myMapView.removeAnnotation(currentSelectedMarkedPointAnnotation)
            
            
            let pointAnnotation = MKPointAnnotationCustom()
            pointAnnotation.coordinate = marklocation
            pointAnnotation.title = data
            pointAnnotation.userData = markedPointAnnotations.count
            
            myMapView.addAnnotation(pointAnnotation)
            
            markedPointAnnotations.append(pointAnnotation)
        }
    
    
    
    func deleteData(boolDelete: Bool) {
        if boolDelete{
            
            print("deleting...")
            markedPointAnnotations.removeAtIndex(currentSelectedMarkedPointAnnotation.userData! - 1)
            myMapView.removeAnnotation(currentSelectedMarkedPointAnnotation)
            
        }
    }
    
    func takeMeHere(TakeMeHere: MKMapItem)
    {
         print("take me here...")
            // From     currentSelectedMarkedPointAnnotation.coordinate
            // To       currentLocation!
        
        calculateSegmentDirections(sourceMapItem!, destMapItem: TakeMeHere)
        
        
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
        var directionsArray = [(startingAddress: String, endingAddress: String, route: MKRoute)]()
        
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

