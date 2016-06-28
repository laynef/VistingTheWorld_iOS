//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/22/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var imageInfoView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    var locations = [Location]()
    var selectedLocation: Location!
    var annotationsLocations = [Int:Location]()
    var fetchedPhotos = [Photo]()
    
    var firstDrop = true
    var longPressRecognizer: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.navigationController?.navigationBarHidden = true
        restoreRegion(false)
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.longPressed(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        let sectionInfo = self.fetchedResultsController.sections![0]
        
        if  !sectionInfo.objects!.isEmpty{
            self.locations = sectionInfo.objects as! [Location]
            for loc in locations{
                let annotation = MKPointAnnotation()
                let tapPoint = CLLocationCoordinate2D(latitude: Double(loc.latitude), longitude: Double(loc.longitude))
                annotation.coordinate = tapPoint
                annotationsLocations[annotation.hash] = loc
                self.mapView.addAnnotation(annotation)
            }
        }
        
        searchBar.delegate = self
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let frcf = fetchedResultsController
        do {
            try frcf.performFetch()
        } catch _ {
        }
        let sectionInfo = frcf.sections![0]
        
        if  !sectionInfo.objects!.isEmpty{
            self.locations = sectionInfo.objects as! [Location]
        }
        
        imageInfoView?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.70)
        imageInfoView.hidden = true
        infoLabel.hidden = true
        self.addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.toolbarHidden = true
        self.view.removeGestureRecognizer(tapRecognizer!)
    }

    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Location")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContent, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    var sharedContent: NSManagedObjectContext {
        return ManagingCoreData.sharedInstance().managingObjectContent!
    }
    
    func searchBar(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let address = searchBar.text{
            let geocoder = CLGeocoder()
            informationBox("Gecoding...", animate: true)
            
            
            geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
                if let _ = error {
                    let alert = UIAlertController(title: "", message: "Geocoding failed", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.informationBox(nil, animate: false)
                } else {
                    if let placemark = placemarks?[0]  {

                        let p = MKPlacemark(placemark: placemark)
                        let span = MKCoordinateSpanMake(1, 1)
                        let region = MKCoordinateRegion(center: p.location!.coordinate, span: span)
                        self.mapView.setRegion(region, animated: true)
                    }
                }
                self.informationBox(nil, animate: false)
            })
        }
    }
    
    
    var annotationsToRemove = [MKPointAnnotation]()
    var annotation = MKPointAnnotation()
    func longPressed(sender: UILongPressGestureRecognizer) -> Bool {

        let networkReachability = try! Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus
        if(networkStatus == .NotReachable){
            displayMessageBox(NetworkErrorMessages.noNetwork)
            return false
        }
        
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        if (sender.state == .Began) {
            let annotation = MKPointAnnotation()
            
            firstDrop = true
            let point:CGPoint = sender.locationInView(self.mapView)
            let tapPoint:CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: self.mapView)
            
            annotation.coordinate = tapPoint
            self.mapView.addAnnotation(annotation)
            self.annotation = annotation
            annotationsToRemove.append(annotation)
            
        } else if (sender.state == .Changed) {
            firstDrop = false
            let annotation = MKPointAnnotation()
            self.mapView.removeAnnotations(annotationsToRemove)
            let point:CGPoint = sender.locationInView(self.mapView)
            let tapPoint:CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: self.mapView)
            annotation.coordinate = tapPoint
            
            self.mapView.addAnnotation(annotation)
            annotationsToRemove.append(annotation)
            self.annotation = annotation
            
        } else if (sender.state == .Ended) {
            firstDrop = false

            selectedLocation = Location(dictionary: [ "latitude": self.annotation.coordinate.latitude, "longitude": self.annotation.coordinate.longitude], context: sharedContent)
            applicationDelegate.stats.locationsAdded += 1
            informationBox("Connecting to Flickr", animate: true)
            Flickr.sharedInstance().populateLocationPhotos(selectedLocation) { (success,photosArray, errorString) in
                if success {
                    if let pd = photosArray {
                        for p in pd{
                            dispatch_async(dispatch_get_main_queue()) {
                                let photo = Photo(dictionary: ["title": p[0], "imagePath":p[1]], context: self.sharedContent)
                                photo.location = self.selectedLocation
                                applicationDelegate.stats.photosDisplayed += 1
                                
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        ManagingCoreData.sharedInstance().saveContent()
                    }

                    let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WholeCollectionViewController") as! DetailViewController
                    detailController.location = self.selectedLocation
                    
                    self.annotationsLocations[self.annotation.hash] = self.selectedLocation
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.informationBox(nil,animate:false)
                        self.navigationController!.pushViewController(detailController, animated: true)
                    }
                    
                    self.mapView.deselectAnnotation(self.annotation, animated: false)
                    self.annotationsToRemove = []
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.informationBox(nil,animate:false)
                        self.displayMessageBox(errorString!)
                        self.mapView.removeAnnotation(self.annotation)
                        ManagingCoreData.sharedInstance().deleteLocObects(self.selectedLocation)
                        print(errorString!)
                    })
                }
            }
        }
        
        return true
    }
    
    var filesPath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
}

// MARK: - Map View Controller (Helper Methods)
extension MapViewController {
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func informationBox(msg:String?,let animate:Bool){
        if let _ = msg{
            if(animate){
                indicator.startAnimating()
            }
            imageInfoView.hidden = false
            infoLabel.hidden = false
            infoLabel.text = msg
        }else{
            imageInfoView.hidden = true
            infoLabel.hidden = true
            indicator.stopAnimating()
        }
    }
}

// MARK: - Map View Controller (Map View)
extension MapViewController {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveRegion()
    }
}

// MARK: - Map View Controller (Saving)
extension MapViewController {
    
    func saveRegion() {
        
        let dict = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        NSKeyedArchiver.archiveRootObject(dict, toFile: filesPath)
    }
    
    func restoreRegion(animated: Bool) {
        
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filesPath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(savedRegion, animated: animated)
            
        } else {
            
            let span = MKCoordinateSpanMake(80, 80)
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.628595, longitude: 22.945351), span: span)
            self.mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: - Map View Controller (Map Views)
extension MapViewController {
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WholeCollectionViewController") as! DetailViewController
        if let loc = annotationsLocations[view.annotation!.hash] {
            detailController.location = loc
            selectedLocation = loc
            
            if let p = loc.photos {
                if p.isEmpty {
                    informationBox("Connecting to Flickr",animate:true)
                    Flickr.sharedInstance().populateLocationPhotos(selectedLocation) { (success,photosArray, errorString) in
                        if success {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.informationBox(nil,animate:false)
                                let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("WholeCollectionViewController") as! DetailViewController
                                detailController.location = loc
                                
                                if let pd = photosArray {
                                    for p in pd {
                                        let photo = Photo(dictionary: ["title": p[0], "imagePath": p[1]], context: self.sharedContent)
                                        photo.location = self.selectedLocation
                                        ManagingCoreData.sharedInstance().saveContent()
                                    }
                                }
                                self.navigationController!.pushViewController(detailController, animated: true)
                            }
                        } else {
                            dispatch_async(dispatch_get_main_queue(), {
                                self.informationBox(nil,animate:false)
                                self.displayMessageBox("No available Photos Found")
                                self.mapView.removeAnnotation(view.annotation!)
                                ManagingCoreData.sharedInstance().deleteLocObects(self.selectedLocation)
                                print(errorString!)
                            })
                        }
                    }
                } else {
                    self.navigationController!.pushViewController(detailController, animated: true)
                }
            }
        }
        self.mapView.deselectAnnotation(view.annotation, animated: false)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            
            pinAnnotationView.pinTintColor = UIColor.greenColor()
            pinAnnotationView.draggable = false
            
            pinAnnotationView.canShowCallout = false
            firstDrop ? (pinAnnotationView.animatesDrop = true) : (pinAnnotationView.animatesDrop = false)
            
            return pinAnnotationView
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if(newState == .Starting) {
            if let loc = annotationsLocations[view.annotation!.hash] {
                ManagingCoreData.sharedInstance().deleteLocObects(loc)
            }
        }
        if(newState == .Ending){
            
            print("change")
            
            let _ = Location(dictionary: ["latitude":view.annotation!.coordinate.latitude,"longitude":view.annotation!.coordinate.longitude], context: sharedContent)
            
            ManagingCoreData.sharedInstance().saveContent()
            
        }
    }
    
}