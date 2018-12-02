//
//  ViewController.swift
//  Maps Part 4
//
//  Created by Sagar Sandy on 28/11/18.
//  Copyright © 2018 Sagar Sandy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapViewOutlet: MKMapView!
    // User defined variables
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initializing location manager delegate
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        // Setting up location manager properties
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        
        // Initializing mapview delegate
        mapViewOutlet.delegate = self
        
        // Setting up mapview properties
        mapViewOutlet.showsUserLocation = true
        
    }
    
    
    //MARK: Search button pressed related action
    @IBAction func searchButtonPressed(_ sender: Any) {
        
        let alertVC = UIAlertController(title: "Enter Coffee shop or Hotels.. etc", message: nil, preferredStyle: .alert)
        
        alertVC.addTextField { (textField) in }
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            if let textField = alertVC.textFields?.first {
                
                let searchTerm = textField.text
                
                    // Searching for nearby places using search term
                    self.findNearByPlacesWith(placeName: searchTerm!)

                }
                
            }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in }
        
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: Searching nearby places using the search term
    func findNearByPlacesWith(placeName : String) {
        
        // Removing previously searched annotations
        let annotations = mapViewOutlet.annotations
        mapViewOutlet.removeAnnotations(annotations)
        
        // Creating search request
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = placeName
        request.region = self.mapViewOutlet.region
        
        let search = MKLocalSearch(request: request)
        
        // Search operation
        search.start(completionHandler: { (response, error) in
            
            guard let response = response, error == nil else {
                return
            }
            
            for mapItem in response.mapItems {
                self.addAnnoatationToMapBasedOnPlacemark(placemark : mapItem.placemark)
            }
        })
    }
    
    
    // MARK: Add annoation to the mapview based on search term
    func addAnnoatationToMapBasedOnPlacemark(placemark : CLPlacemark) {
        
        if let coordinate = placemark.location?.coordinate {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = placemark.name
            mapViewOutlet.addAnnotation(annotation)
            
        }
        
    }

    
    // MARK: Checking user gave permission or not for locations
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("yup")
        } else {
            print("something went wrong")
        }
        
        if status == .denied {
            print("dude, this is not correct")
        }
    }
    
}

// MARK: Map view delegate methods extension

extension ViewController : MKMapViewDelegate {
    
    // This method will be called upon updating user location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        // Zooming into current user location
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
        
        
        print("user location changed")
    }
    
    // This method will return locations even in background mode also, didupdate user location will not fire in background mode. We need to use this method to get backgound location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location changed again")
        
        
    }
    
    // MARK: This delegate method will be called once user clicks on a particular annotation
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        // Opening the default map app, when user clicks on a particular annotation
        if let annotation = view.annotation {
            
            let coordinate = annotation.coordinate
            
            let destinationPlaceMark = MKPlacemark(coordinate: coordinate)
            
            let destinationMapItem = MKMapItem(placemark: destinationPlaceMark)
            
            MKMapItem.openMaps(with: [destinationMapItem], launchOptions: nil)
            
        }
        
    }
    
}

