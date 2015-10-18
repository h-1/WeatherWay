//
//  LoadingViewController.swift
//  WeatherWayApp
//
//  Created by Lucas Farah on 10/17/15.
//  Copyright © 2015 Lucas Farah. All rights reserved.
//

import UIKit
//import NVActivityIndicatorView
import EventKit
import Alamofire

class LoadingViewController: UIViewController {
  
  let manager = CLLocationManager()
  
  @IBOutlet weak var blankView: UIView!
  
  var event: EKEvent!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print(event)
    let location = event.structuredLocation
    print("lat: \(location?.geoLocation?.coordinate.latitude)")
    print("lng: \(location?.geoLocation?.coordinate.longitude)")
    
    
    let arr = self.getDirectionsForLatitude((location?.geoLocation?.coordinate.latitude)!, longitude: (location?.geoLocation?.coordinate.longitude)!)
    
    // Do any additional setup after loading the view.
    //      let nv = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    //      self.blankView.addSubview(nv)
    
      }
  
  func getCurrentLocation() -> CLLocation
  {
    var locManager = CLLocationManager()
    locManager.requestAlwaysAuthorization()
    var currentLocation = CLLocation!()
    
    if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways ||
      CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
        
        currentLocation = locManager.location
        return currentLocation
    }
    return CLLocation()
  }
  
  func getDirectionsForLatitude(latitude:CLLocationDegrees,longitude:CLLocationDegrees) -> NSMutableArray
  {
    var arrResult = NSMutableArray()
    
    let currentLoc = self.getCurrentLocation()
    Alamofire.request(.GET, "http://192.168.0.15:5000/?cLat=\(currentLoc.coordinate.latitude)&cLng=\(currentLoc.coordinate.longitude)&dLat=\(latitude)&dLng=\(longitude)").responseJSON { response in
      print(response.request)
      if let JSON = response.result.value {
        print("JSON: \(JSON)")
          self.performSegueWithIdentifier("routeLoaded", sender: JSON)
      }
      
      
    }
    return arrResult
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let theDestination = (segue.destinationViewController as! ViewController)
    let routes = sender as! [NSDictionary]
    theDestination.directions = routes
  }
  

}
