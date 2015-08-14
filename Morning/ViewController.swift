//
//  ViewController.swift
//  Yelp
//
//  Created by Kristen on 2/8/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    var client: YelpClient!
    var animator : ARNModalTransitonAnimator?
    @IBOutlet weak var yelpLogo: UIImageView!
    @IBOutlet private weak var businessMapView: MKMapView! // make strong?
    @IBOutlet private weak var businessTableView: UITableView! // make strong?
    private let yelpConsumerKey = "wpX5b8fg8wIl4HhByeoEbw"
    private let yelpConsumerSecret = "Y51H_rJrpftusR6FwxQwh2NmoC0"
    private let yelpToken = "-qG1KVmJnbQ6Vp_iuG4EXMkEAZqd056L"
    private let yelpTokenSecret = "UMQ8ZA4bB39yN4zxTIgOykY2B04"

    private var businesses = [Business]()
    private let businessLimit = 20
    private var scrollOffset = 20
    var keyterm : String!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        businessTableView.dataSource = self
        businessTableView.delegate = self
        businessMapView.delegate = self
        businessTableView.registerNib(UINib(nibName: "BusinessCell", bundle: nil), forCellReuseIdentifier: "BusinessCell")
        businessTableView.estimatedRowHeight = 90
        businessTableView.rowHeight = UITableViewAutomaticDimension

        var settingsArray = NSUserDefaults.standardUserDefaults().objectForKey("search") as! [NSNumber]
        if var index = find(settingsArray, NSNumber(bool: true)){
            switch (index){
            case 0:
                keyterm = "coffee"
                break
            case 1:
                keyterm = "gas station"
                break
            case 2:
                keyterm = "breakfast"
                break
            case 3:
                keyterm = "bars"
                break
            default:
                keyterm = "coffee"
                break
            }
        }
        
        definesPresentationContext = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        yelpLogo.layer.cornerRadius = yelpLogo.frame.size.width/2.0
        yelpLogo.layer.masksToBounds = true
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        
        client = YelpClient(long : "\(locValue.latitude)", lat : "\(locValue.longitude)", consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        fetchBusinessesWithQuery(self.keyterm, params: ["limit": "20", "sort" : "1"])

        locationManager.stopUpdatingLocation()
        self.businessTableView.reloadData()
    }
    
    private func fetchBusinessesWithQuery(query: String, params: [String: String] = [:]) {

        client.searchWithTerm(query, additionalParams: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let json = JSON(response)
            self.scrollOffset = self.businessLimit
            
            if let businessessArray = json["businesses"].array {
                self.businesses = Business.businessWithDictionaries(businessessArray)
            } else { // TODO: maybe don't clear out data when request doesn't work?
                self.businesses = []
            }
            
            
            self.businessTableView.reloadData()
            self.updateMapViewAnnotations()
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error.description)
        }

    }
    
    private func fetchInfiniteScrollBusinessesWithQuery(query: String, params: [String: String] = [:]) {

        client.searchWithTerm(query, additionalParams: params, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            let json = JSON(response)
            
            if let businessessArray = json["businesses"].array {
                self.businesses.extend(Business.businessWithDictionaries(businessessArray))
            }
            
            self.businessTableView.reloadData()

            self.scrollOffset += 20
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println(error.description)
        }

    }
    
    //MARK - UITableViewDataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.businesses.count

    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell") as! BusinessCell
     
        cell.setBusiness(businesses[indexPath.row], forIndex: indexPath.row)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // segue to detailviewcontroller
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsViewController = storyboard.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        var navController = UINavigationController(rootViewController: detailsViewController)
        detailsViewController.placeName = self.businesses[indexPath.row].title
        detailsViewController.business = self.businesses[indexPath.row]
        
        self.animator = ARNModalTransitonAnimator(modalViewController: navController)
        self.animator!.behindViewAlpha = 0.5
        self.animator!.behindViewScale = 0.9
        self.animator!.transitionDuration = 0.7
        self.animator!.dragable = true
        self.animator!.direction = .Bottom
        
        navController.transitioningDelegate = self.animator!
        self.presentViewController(navController, animated: true, completion: nil)
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let actualPosition = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - businessTableView.frame.height
        if actualPosition >= contentHeight {

            
        fetchInfiniteScrollBusinessesWithQuery(self.keyterm, params: ["limit" : "\(self.businessLimit)", "offset": "\(self.scrollOffset)"])
        }
    }
    
    private func updateMapViewAnnotations() {
        businessMapView.removeAnnotations(businessMapView.annotations)
        businessMapView.addAnnotations(businesses)
        businessMapView.showAnnotations(businesses, animated: true)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if (annotation.isEqual(businessMapView.userLocation)){
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("MapViewAnnotation")
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MapViewAnnotation")
            view.canShowCallout = true
            
            let imageView = UIImageView(frame: CGRectMake(0, 0, 46, 46))
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
            
            if let img = (annotation as! Business).imageURL{
                imageView.setImageWithURL(NSURL(string:(annotation as! Business).imageURL!))
            }

            view.leftCalloutAccessoryView = imageView
            let disclosureButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
            disclosureButton.setImage(UIImage(named: "flag"), forState: UIControlState.Normal)
            disclosureButton.frame = CGRectMake(0.0, 0.0, 35.0, 35.0)
            disclosureButton.contentMode = UIViewContentMode.ScaleToFill
            view.rightCalloutAccessoryView = disclosureButton
        }
        
        view.annotation = annotation
        
        return view
    }

    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control == view.rightCalloutAccessoryView {
            
       
            var selectedBusiness = view.annotation as! Business
            
            var latitute:CLLocationDegrees =  selectedBusiness.latitude!
            var longitute:CLLocationDegrees =  selectedBusiness.longitude!
            
            let regionDistance:CLLocationDistance = 10000
            var coordinates = CLLocationCoordinate2DMake(latitute, longitute)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            var options = [
                MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
            ]
            var placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            var mapItem = MKMapItem(placemark: placemark)
            mapItem.name = "\(selectedBusiness.name)"
            mapItem.openInMapsWithLaunchOptions(options)
            
        }
    }
    
}

