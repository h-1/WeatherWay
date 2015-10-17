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

  @IBOutlet weak var blankView: UIView!
  
  var event: EKEvent!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      print(event)
      let location = event.structuredLocation
      print("lat: \(location?.geoLocation?.coordinate.latitude)")
      print("lng: \(location?.geoLocation?.coordinate.longitude)")
      let arr = self.getDirectionsForLatitude(23.23, longitude: 23.23)
        // Do any additional setup after loading the view.
//      let nv = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//      self.blankView.addSubview(nv)

    }
  
  func getDirectionsForLatitude(latitude:CLLocationDegrees,longitude:CLLocationDegrees) -> NSMutableArray
  {
    var arrResult = NSMutableArray()
    
    Alamofire.request(.GET, "http://192.168.0.15:5000/?cLat=47.609219&cLng=-122.425204&dLat=47.520328&dLng=-122.320398").responseJSON { response in
      if let JSON = response.result.value {
        print("JSON: \(JSON)")
        
        /*
        - latitude,longitude


*/
      }
      
      
    }
    return arrResult
  }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
