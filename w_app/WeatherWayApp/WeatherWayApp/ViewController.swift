//
//  ViewController.swift
//  WeatherWayApp
//
//  Created by Lucas Farah on 10/11/15.
//  Copyright © 2015 Lucas Farah. All rights reserved.
//

import UIKit
import MapKit
import Polyline
class ViewController: UIViewController,MKMapViewDelegate {
  
  @IBOutlet weak var butLetsGo: UIButton!
  @IBOutlet weak var map: MKMapView!
  var myRoute : MKRoute?
  var isBlue = false
  
  var polyFinal = MKPolyline()
  
  @IBOutlet weak var seg: UISegmentedControl!
  var route:MKRoute! = MKRoute()
  var directions = [NSDictionary]()
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.\
    self.map.delegate = self
    
    print("directions:\(directions)")
      var arrayCoordinates = [CLLocationCoordinate2D]()
    for item in directions
    {
        print(item)
        let start = item["start_location"] as! NSDictionary
        let end = item["end_location"] as! NSDictionary
        
        let point1 = MKPointAnnotation()
        let point2 = MKPointAnnotation()
        
        if let lat = start["lat"],lng = start["lng"],eLat = end["lat"],eLng = end["lng"]
        {
          let coordinateS = CLLocationCoordinate2D(latitude: (lat as? Double)!, longitude: (lng as? Double)!)
          let coordinateE = CLLocationCoordinate2D(latitude: (eLat as? Double)!, longitude: (eLng as? Double)!)
          arrayCoordinates.append(coordinateS)
          arrayCoordinates.append(coordinateE)
          print("---- ADDED")
        }
        
      }
    
    //
      //      let route = MKRoute()
      //      let polyline = Polyline(coordinates: arrayCoordinates)
      //      let encodedPolyline: String = polyline.encodedPolyline
      //      print(encodedPolyline)
      //      self.route.polyline.getCoordinates(&arrayCoordinates, range: NSMakeRange(0, arrayCoordinates.count))
      //      print(self.route.polyline)
      let poly = MKPolyline(coordinates: &arrayCoordinates, count: arrayCoordinates.count)
      self.polyFinal = poly
      self.map.insertOverlay(poly, atIndex: 0)

    //ROund corner
    self.butLetsGo.layer.cornerRadius = 10 // this value vary as per your desire
    self.butLetsGo.clipsToBounds = true
  }
  
  //  func fetch()
  //  {
  //      let url = NSURL(string: "https://frozen-island-1739.herokuapp.com/addUser?email=\(email)&password=\(password)&name=\(name)")
  //      print(url?.absoluteString)
  //
  //      let request = NSURLRequest(URL: url!)
  //
  //      NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
  //
  //        self.performSegueWithIdentifier("login", sender: self)
  //      }
  //
  //
  //
  //  }
  
  @IBAction func segChanged(sender: AnyObject)
  {
    switch self.seg.selectedSegmentIndex
    {
    case 0:
      //do something

      break
    case 1:
      //do something else

      break
    default:
      break;
    }
  }
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    
    let myLineRenderer = MKPolylineRenderer(polyline: polyFinal)
    if isBlue
    {
      myLineRenderer.strokeColor = UIColor.blueColor()
    }
    else
    {
      myLineRenderer.strokeColor = UIColor.redColor()
      
    }
    myLineRenderer.lineWidth = 3
    return myLineRenderer
  }
}

