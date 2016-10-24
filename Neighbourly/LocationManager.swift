//
//  LocationManager.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-20.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import Foundation
import CoreLocation


class LocationManager: NSObject, CLLocationManagerDelegate {
    
    fileprivate let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    fileprivate let apiKey = "AIzaSyCtiXoiVDbhxBzwmmOGnBGotFZydvaizSY"
    
    private var locationManager: CLLocationManager!
    private var lastLocation: CLLocation?
    
    static let shared = LocationManager()
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    func setupLocationManager(){
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else{return}
        
        let timeSinceLastLocationUpdate = Double.abs(location.timestamp.timeIntervalSinceNow)
        
        if(timeSinceLastLocationUpdate < 10.0){
            lastLocation = location
        }
    }
    
    func getReverseGeocodeLocation(completion: @escaping (String, CLLocation?) -> Void){
        
        guard let location = lastLocation else{completion("No connection!", nil);return}
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
            {(placemarks, error) in
                if (error != nil) {print("reverse geodcode fail: \(error?.localizedDescription)")}
                guard let placemark = placemarks?.first else {return}
                completion("\(placemark.subLocality!), \(placemark.locality!), \(placemark.administrativeArea!)", location)
        })
    }
    
}
