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
