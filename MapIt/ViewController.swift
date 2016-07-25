//
//  ViewController.swift
//  MapIt
//
//  Created by Liya Wu-17 on 7/5/16.
//  Copyright © 2016 ms. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//  Anything that conforms to this protocol has to implement a method called dropPinZoomIn(_:)
protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var resultSearchController:UISearchController? = nil
    
    var selectedPin:MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // want to override the default accuracy level with an explicit value
        locationManager.requestWhenInUseAuthorization() // triggers the location permission dialog
        locationManager.requestLocation() // triggers a one-time location request
    
        // locationSearchTable is the Table View Controller
        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
    
        // configures the search bar and embeds it within the navigation bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false // determines whether the Navigation Bar disappears when the search results are shown. Set this to false, since we want the search bar accessible at all times.
        resultSearchController?.dimsBackgroundDuringPresentation = true // gives the modal overlay a semi-transparent background when the search bar is selected
        definesPresentationContext = true // By default, the modal overlay will take up the entire screen, covering the search bar. definesPresentationContext limits the overlap area to just the View Controller’s frame instead of the whole Navigation Controller.
    
        locationSearchTable.mapView = mapView // passes along a handle of the mapView from the main View Controller onto the locationSearchTable
    
        locationSearchTable.handleMapSearchDelegate = self // The parent (ViewController) passes a handle of itself to the child controller (LocationSearchTable)
        
    }
   
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) { // called when the user responds to the permission dialog
        if status == .AuthorizedWhenInUse { // if allowed
            locationManager.requestLocation() // the first request would have suffered a permission failure
        }
    }
    
    //gets called when location information comes back
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first { // gets an array of locations but only interested in the first one

            //zooming into current location
            let span = MKCoordinateSpanMake(0.05, 0.05) // zoom level
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true) //defining a map region - combination of the map center (coordinate) and zoon level (span)
        }
    }
    
    // FOR NOW: just prints out the rror
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("hello")
    }
    
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){ // implements the dropPinZoomIn() method in order to adopt the HandleMapSearch protocol
        // cache the pin
        selectedPin = placemark // incoming placemark
        // clear existing pins
        //mapView.removeAnnotations(mapView.annotations) // clears the map of any existing annotations
        let annotation = MKPointAnnotation() // map pin that contains a coordinate, title, and subtitle
        annotation.coordinate = placemark.coordinate // placemark has similar information like a coordinate and address information
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        //let button = UIButton()
        mapView.addAnnotation(annotation) // adds the above annotation to the map.
        //button.setTitle(name, forState: .Normal)
        
        let span = MKCoordinateSpanMake(0.05, 0.05) // specifies a zoom level
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true) // zooms the map to the coordinate
        
        
        /* GEOFENCING
         
        let regionIdentifier = placemark.name ?? "no name"
        // var makeSchoolCoord = CLLocationCoordinate2DMake(40.7184243, -74.004693)
        
        // 805 is 1/2 a mile
        var makeSchoolRegion = CLCircularRegion(center: placemark.coordinate, radius: 200, identifier: regionIdentifier)
        
        locationManager.startMonitoringForRegion(makeSchoolRegion)
        
         */
        
//        let button = UIButton(type: UIButtonType.Custom)
//        button.imageView?.image = UIImage(named: "info.jpg")
//        var annotationView: MKAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
//        annotationView.rightCalloutAccessoryView = button
//        annotationView.addSubview(button)
    }
}

extension ViewController: MKMapViewDelegate{
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {

    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("AnnotationView Id")
        if let annotation = annotation as? MKUserLocation{
            return nil
        }
        if view == nil{
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView Id")
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        view?.leftCalloutAccessoryView = nil
        view?.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
        //swift 1.2
        //view?.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        
        return view
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
  
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegueWithIdentifier("nextViewController", sender: view)
            
        }
    }
}