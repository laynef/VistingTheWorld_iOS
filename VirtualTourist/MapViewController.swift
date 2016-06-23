//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/22/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mapStackView: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var wholeStackView: UIStackView!
    
    var enabledEditButton: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initialLaunch()
    }
    
    /* Delete pins that were placed */
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        
    }
    
    /* Toggle between edit and search states */
    @IBAction func editButtonPressed(sender: AnyObject) {
        if (enabledEditButton == false) {
            editButton.title = "Done"
            buttonStackView.hidden = false
            enabledEditButton = true
        } else {
            editButton.title = "Edit"
            enabledEditButton = false
            buttonStackView.hidden = true
        }
    }
    
    

} // end of MapViewController

// MARK: -  MapViewController (Views Methods)
extension MapViewController {
    
    /* initial first launch of the app */
    private func initialLaunch() {
        buttonStackView.hidden = true
    }
    
}

// MARK: - MapViewController: MKMapViewDelegate (Pins)
extension MapViewController: MKMapViewDelegate {
    
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
                    showAlert("Images unavailable", messages: "URL could not open. Please try again.")
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


// MARK: - MapViewController (Persistance)
extension MapViewController {
    
}

// MARK: - MapViewController ()
extension MapViewController {
    
}