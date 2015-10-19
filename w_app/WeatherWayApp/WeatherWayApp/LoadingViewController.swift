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
import NVActivityIndicatorView


class LoadingViewController: UIViewController {
  
  let manager = CLLocationManager()
  
  @IBOutlet weak var loader: UIView!
  @IBOutlet weak var blankView: UIView!
  
  @IBOutlet weak var lblAnalysing: UILabel!
  var event: EKEvent!
  
  var index = 0
  var arrayAnalysing = ["fog",
    "rain",
    "snow",
    "snowfall",
    "snowdepthi",
    "hail",
    "thunder",
    "tornado",
    "meantempi",
    "meandewpti",
    "meanpressurei",
    "meanwindspdi",
    "meanwdire",
    "meanwdird",
    "meanvisi",
    "humidity",
    "maxtempi",
    "mintempi",
    "maxhumidity",
    "minhumidity",
    "maxdewpti",
    "mindewpti",
    "maxpressurei",
    "minpressurei",
    "maxwspdi",
    "minwspdi",
    "maxvisi",
    "minvisi",
    "precipi"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print(event)
    let location = event.structuredLocation
    print("lat: \(location?.geoLocation?.coordinate.latitude)")
    print("lng: \(location?.geoLocation?.coordinate.longitude)")
    
    
    self.getDirectionsForLatitude((location?.geoLocation?.coordinate.latitude)!, longitude: (location?.geoLocation?.coordinate.longitude)!)
    
    // Do any additional setup after loading the view.
    //      let nv = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    //      self.blankView.addSubview(nv)
    let timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "changeLabel", userInfo: nil, repeats: true)
    
    self.showLoader()
  }
  
  func showLoader()
  {
    let activityTypes: [NVActivityIndicatorType] = [
      .BallTrianglePath]
    let cols = 1
    let rows = 1
    let cellWidth = Int(self.view.frame.width / CGFloat(cols))
    let cellHeight = 200
    
    for var i = 0; i < activityTypes.count; i++ {
      let x = i % cols * cellWidth
      let y = i / cols * cellHeight
      let frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
      let activityIndicatorView = NVActivityIndicatorView(frame: frame,
        type: activityTypes[i])
      
      self.view.addSubview(activityIndicatorView)
      
      activityIndicatorView.startAnimation()
    }
  }
  func changeLabel()
  {
    if index < self.arrayAnalysing.count
    {
      self.lblAnalysing.fadeOut()
      self.lblAnalysing.text = self.arrayAnalysing[self.index]
      self.lblAnalysing.fadeIn()
      
      self.index += 1
    }
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
  
  func getDirectionsForLatitude(latitude:CLLocationDegrees,longitude:CLLocationDegrees)
  {
    let currentLoc = self.getCurrentLocation()
    Alamofire.request(.GET, "http://weatherway.mybluemix.net/?cLat=\(currentLoc.coordinate.latitude)&cLng=\(currentLoc.coordinate.longitude)&dLat=\(latitude)&dLng=\(longitude)").responseJSON { response in
      print(response.request)
      if let JSON = response.result.value {
        print("JSON: \(JSON)")
        
        let currentLoc = self.getCurrentLocation()
        Alamofire.request(.GET, "http://weatherway.mybluemix.net/getStepsFromGoogle?cLat=\(currentLoc.coordinate.latitude)&cLng=\(currentLoc.coordinate.longitude)&dLat=\(latitude)&dLng=\(longitude)").responseJSON { response in
          print(response.request)
          if let JSON2 = response.result.value {
            print("JSON: \(JSON2)")
            let arrFinal = [JSON,JSON2]
            self.performSegueWithIdentifier("routeLoaded", sender: arrFinal)
          }
          
          
        }
      }
      
      
    }  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let theDestination = (segue.destinationViewController as! ViewController)
    let routes = sender as! [[NSDictionary]]
    theDestination.directions = routes
  }
  
  
}

extension UIView {
  func fadeIn() {
    // Move our fade out code from earlier
    UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
      self.alpha = 1.0 // Instead of a specific instance of, say, birdTypeLabel, we simply set [thisInstance] (ie, self)'s alpha
      }, completion: nil)
  }
  
  func fadeOut() {
    UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
      self.alpha = 0.0
      }, completion: nil)
  }
}
