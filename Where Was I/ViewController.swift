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
    
    var internalData : String?
    var locationManager = CLLocationManager()
    var marklocation = CLLocationCoordinate2D()
    var locationPointAnnotation = MKPointAnnotation()
    var userZoom : Double = 0
    
    var markedPointAnnotations = [MKPointAnnotationCustom()]
    var currentSelectedMarkedPointAnnotation = MKPointAnnotationCustom()
   
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var myMapView: MKMapView!
    
    
    
    
    @IBAction func returned(segue: UIStoryboardSegue)
    {
        print("Segue Unwound")
        print("internalData=\(internalData)")
        
        
        markedPointAnnotations.removeAtIndex(currentSelectedMarkedPointAnnotation.userData! - 1)
        
        let marklocation : CLLocationCoordinate2D = currentSelectedMarkedPointAnnotation.coordinate
        
        
        myMapView.removeAnnotation(currentSelectedMarkedPointAnnotation)
        
        
        let pointAnnotation = MKPointAnnotationCustom()
        pointAnnotation.coordinate = marklocation
        pointAnnotation.title = internalData
        pointAnnotation.userData = markedPointAnnotations.count
            
        myMapView.addAnnotation(pointAnnotation)
        
        markedPointAnnotations.append(pointAnnotation)
        
    
    }
    
    @IBAction func MarkLocationButtonTapped(sender: AnyObject) {
        
        print ("MarkLocationButtonTapped")
        
        //myMapView.centerCoordinate
        //locationManager.location?.coordinate
        
        
        marklocation = myMapView.centerCoordinate
        
        print ("Location marked at \(marklocation)")
        
        let pointAnnotation = MKPointAnnotationCustom()
        pointAnnotation.coordinate = marklocation
        pointAnnotation.title = "Marked Location"
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
        
        let location = CLLocationCoordinate2D(latitude : locations[locations.count - 1].coordinate.latitude, longitude: locations[locations.count - 1].coordinate.longitude)
        
        
        if let ha  = manager.location?.horizontalAccuracy
        {
            
            let myRegion = MKCoordinateRegionMakeWithDistance(location, ha , ha)
            
            myMapView.setRegion(myRegion, animated: true)
            
            //print (location)
            
            
            
            
            if locationPointAnnotation.title != nil
            {
                myMapView.removeAnnotation(locationPointAnnotation)
            }
            
            locationPointAnnotation.coordinate = location
            locationPointAnnotation.title = "Your Location"
           
            myMapView.addAnnotation(locationPointAnnotation)
            
            
            
            
            statusLabel.text = "Found Your Location"
            //locationManager.stopUpdatingLocation()
            
            //MKCircle
            let circle = MKCircle(centerCoordinate: location, radius: 10)
            myMapView.addOverlay(circle)
            
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
            
            let route = overlay as! MKPolyline
            let routeRenderer = MKPolylineRenderer(polyline: route)
            routeRenderer.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.6)
            let pattern = [2, 5]
            routeRenderer.lineDashPattern = pattern
            routeRenderer.lineWidth = 3
            return routeRenderer
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
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print (error.description)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowPopoverFromPin"
        {
        
            let myPopoverController = segue.destinationViewController
        
            myPopoverController.setValue(currentSelectedMarkedPointAnnotation.title!, forKey : "originalMarkedLocationName")
            
            (segue.destinationViewController as! PopoverContentViewController).delegate = self
        
        }
    }
    
}

extension ViewController: MarkedLocationDelegate {
        func updateData(data: String) {
            self.internalData = data
        }
}

