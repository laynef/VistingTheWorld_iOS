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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

// MARK: - MapViewController ()
extension MapViewController {
    
}