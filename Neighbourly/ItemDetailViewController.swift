//
//  ItemDetailViewController.swift
//  Neighbourly
//
//  Created by Dan Christal on 2016-10-18.
//  Copyright © 2016 Dan Christal. All rights reserved.
//

import UIKit
import MapKit

class ItemDetailViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!{
        didSet{
            mapView.mapType = .standard
            mapView.showsUserLocation = true
            mapView.delegate = self
        }
    }

    var item : Item!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = item.description
        mapView = MKMapView()
        imageView.loadImage(urlString: item.imageURL)
        descriptionLabel.text = item.description
        locationLabel.text = item.locationString

    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
        let annotation = MKPointAnnotation()
        let centerCoordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.longitude)
        annotation.coordinate = centerCoordinate
        annotation.title = item.description
        
        mapView.showAnnotations([annotation], animated: true)
        
    }
}
