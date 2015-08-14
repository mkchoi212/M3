//
//  DetailViewController.swift
//  Yelp
//
//  Created by Kristen on 2/14/15.
//  Copyright (c) 2015 Kristen Sundquist. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {

    var business: Business!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var numberOfReviewsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var reviewImageView: UIImageView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var businessMapView: MKMapView!
    @IBOutlet weak var isOpen: UILabel!
    var placeName : String?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        businessMapView.delegate = self
        reviewImageView.layer.cornerRadius = 3
        reviewImageView.clipsToBounds = true
        updateMapViewAnnotation()
        updateUI()
        
        self.title = placeName!
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Stop, target: self, action: "tapCloseButton")
    }
    
    func tapCloseButton() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    func updateUI() {
        
        thumbImageView.contentMode = UIViewContentMode.ScaleAspectFill
        thumbImageView.clipsToBounds = true
        if let imageURL = business.imageURL {
            let url = NSURL(string: imageURL)
            thumbImageView.setImageWithURLRequest(NSMutableURLRequest(URL: url!), placeholderImage: nil, success: { (request, response, image) -> Void in
                self.thumbImageView.image = image
                if (request != nil && response != nil) {
                    self.thumbImageView.alpha = 0.0
                    UIView.animateWithDuration(1.0, animations: { () -> Void in
                        self.thumbImageView.alpha = 1.0
                    })
                }
                }, failure: nil)
        }
        
        nameLabel.text = business.name
        let distance = NSString(format: "%.2f", business.distance)
        distanceLabel.text = "\(distance) mi"
        ratingImageView.contentMode = .ScaleAspectFit
        if let ratingImageURL = business.ratingImageUrl {
            ratingImageView.setImageWithURL(NSURL(string: ratingImageURL))
        }
        numberOfReviewsLabel.text = "\(business.numberOfReviews) Reviews"
        addressLabel.text = business.displayAddress.uppercaseString
        categoryLabel.text = business.categories

        reviewImageView.contentMode = UIViewContentMode.ScaleAspectFit
        if let recomendedReviewImageUrl = business.recomendedReviewImageUrl {
            let url = NSURL(string: recomendedReviewImageUrl)
            reviewImageView.setImageWithURLRequest(NSMutableURLRequest(URL: url!), placeholderImage: nil, success: { (request, response, image) -> Void in
                self.reviewImageView.image = image
                if (request != nil && response != nil) {
                    self.reviewImageView.alpha = 0.0
                    UIView.animateWithDuration(1.0, animations: { () -> Void in
                        self.reviewImageView.alpha = 1.0
                    })
                }
                }, failure: nil)
        }
        if let recomendedReview = business.recomendedReviewText {
            reviewLabel.text = recomendedReview
        }
        if let displayPhone = business.displayPhone {
            phoneButton.setTitle(displayPhone, forState: UIControlState.Normal)
        }
        println(business.closed!)
        if (business.closed! == true){
            isOpen.text = "OPEN"
            isOpen.textColor = UIColor.greenColor()
        }
        else{
            isOpen.text = "CLOSED"
            isOpen.textColor = UIColor.redColor()
        }

    
    }

    
    @IBAction func touchedCallBusinessButton() {
        if let businessPhoneNumber = business.phoneNumber {
            if let url = NSURL(string: "tel://\(businessPhoneNumber)") {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        
    }
    
    private func updateMapViewAnnotation() {
        businessMapView.removeAnnotations(businessMapView.annotations)
        businessMapView.addAnnotation(business)
        businessMapView.showAnnotations([business], animated: true)
    }
    
    @IBAction func startNav(sender: AnyObject) {
        
        var latitute:CLLocationDegrees =  self.business.latitude!
        var longitute:CLLocationDegrees =  self.business.longitude!
        
        let regionDistance:CLLocationDistance = 10000
        var coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        var options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        var placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        var mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.business.name)"
        mapItem.openInMapsWithLaunchOptions(options)
    }
}
