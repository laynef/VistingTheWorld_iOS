//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/22/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit
import MapKit

// reuse id: collectionViewCell

class DetailViewController: UIViewController {
    
    @IBOutlet weak var wholeStackView: UIStackView!
    @IBOutlet weak var mapStackView: UIStackView!
    @IBOutlet weak var collectionStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionViewCell: UICollectionViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}


// MARK: - OTMMapViewController: MKMapViewDelegate
extension DetailViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "Pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let mediaURL = NSURL(string: ((view.annotation?.subtitle)!)!) {
                if UIApplication.sharedApplication().canOpenURL(mediaURL) {
                    UIApplication.sharedApplication().openURL(mediaURL)
                } else {
                    showAlert("Images unavailable", message: "URL could not open. Please try again.")
                }
            }
        }
    }
    
    func showAlert(title: String, messages: String) {
        let alertController = UIAlertController(title: title, message: messages, preferredStyle: .Alert)
        let action = UIAlertAction(title: title, style: .Default, handler: nil)
        alertController.addAction(action)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
