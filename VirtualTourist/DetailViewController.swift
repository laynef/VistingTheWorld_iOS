//
//  DetailViewController.swift
//  VirtualTourist
//
//  Created by Layne Faler on 6/22/16.
//  Copyright © 2016 Layne Faler. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var infoBoxLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var detailIndicator: UIActivityIndicatorView!
    
    var prefetchedPhotos: [Photo]!
    var newCollectionButton:UIBarButtonItem!
    var location:Location!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.toolbarHidden = false
        
            do {
                try fetchedResultsController.performFetch()
            } catch _ {
                print("Fetching error")
            }
        
        fetchedResultsController.delegate = self
        
        infoImageView?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        infoImageView.hidden = true
        infoBoxLabel.hidden = true
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.toolbarHidden = false
        
        setRegion()
        

        newCollectionButton = UIBarButtonItem(title: "New Collection", style: .Plain, target: self, action: #selector(DetailViewController.newCollection))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        newCollectionButton.tintColor =  UIColor(red: (255/255.0), green: (0/255.0), blue: (132/255.0), alpha: 1.0)
        self.toolbarItems = [flexSpace,newCollectionButton,flexSpace]
    }
    
    var sharedContext: NSManagedObjectContext {
        return ManagingCoreData.sharedInstance().managingObjectContent!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "location == %@", self.location);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Delete:
                self.collectionView.deleteItemsAtIndexPaths([indexPath!])
            case .Update:
                let cell = self.collectionView.cellForItemAtIndexPath(indexPath!) as! CollectionViewCell
                let photo = controller.objectAtIndexPath(indexPath!) as! Photo
                cell.collectionImageView.image = photo.image
            default:
                return
            }
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.prefetchedPhotos = self.fetchedResultsController.fetchedObjects as! [Photo]
        
        return prefetchedPhotos!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
        
        if let photo = NSKeyedUnarchiver.unarchiveObjectWithFile(Flickr.sharedInstance().imagePath((prefetchedPhotos![indexPath.row].imagePath as NSString).lastPathComponent)) as? UIImage {
            cell.collectIndicator.stopAnimating()
            cell.collectionImageView.image = photo
        } else {
            cell.collectIndicator.startAnimating()
            cell.collectionImageView.image = UIImage(named: "PlaceHolder")
            Flickr.sharedInstance().downloadImageAndSetCell(prefetchedPhotos![indexPath.row].imagePath,cell: cell,completionHandler: { (success, errorString) in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.collectIndicator.stopAnimating()
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.collectIndicator.stopAnimating()
                    })
                }
            })
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        ManagingCoreData.sharedInstance().deletePicObject(photo)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(4.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CGFloat(4.0)
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 10.0)
    }
    
    func setRegion() {
        let span = MKCoordinateSpanMake(2, 2)
        let coordinates = CLLocationCoordinate2D(latitude: Double(location.latitude), longitude: Double(location.longitude))
        let region = MKCoordinateRegion(center: coordinates, span: span)
        let annotation = MKPointAnnotation()
        let tapPoint:CLLocationCoordinate2D = coordinates
        annotation.coordinate = tapPoint
        
        self.mapView.addAnnotation(annotation)
        self.mapView.setRegion(region, animated: true)
    }
    
    func newCollection() -> Bool {
        
        let networkReachability = try! Reachability.reachabilityForInternetConnection()
        let networkStatus = networkReachability.currentReachabilityStatus
        
        if(networkStatus == .NotReachable) {
            displayMessageBox(NetworkErrorMessages.noNetwork)
            return false
        }
        
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        informationBox("Connecting to Flickr",animate:true)
        newCollectionButton.enabled = false
        Flickr.sharedInstance().populateLocationPhotos(location) { (success,photosArray, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    for p in self.location.photos! {
                        ManagingCoreData.sharedInstance().deletePicObject(p)
                    }
                    
                    if let pd = photosArray {
                        for p in pd {
                            let photo = Photo(dictionary: ["title": p[0], "imagePath": p[1]], context: self.sharedContext)
                            photo.location = self.location
                            applicationDelegate.stats.photosDisplayed += 1
                        }
                        ManagingCoreData.sharedInstance().saveContent()
                    }
                    self.informationBox(nil, animate:false)
                    self.newCollectionButton.enabled = true
                    self.collectionView.reloadData()
                })
            } else {
                self.informationBox(nil, animate:false)
                self.displayMessageBox(errorString!)
                self.newCollectionButton.enabled = true
                print(errorString!)
            }
        }
        return true
    }
}

// MARK: - Detail View Controller (Error Handling)
extension DetailViewController {
    
    func displayMessageBox(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func informationBox(msg:String?,let animate:Bool){
        if let _ = msg{
            if(animate){
                detailIndicator.startAnimating()
            }
            infoImageView.hidden = false
            infoBoxLabel.hidden = false
            infoBoxLabel.text = msg
        }else{
            infoImageView.hidden = true
            infoBoxLabel.hidden = true
            detailIndicator.stopAnimating()
        }
    }
    
}

