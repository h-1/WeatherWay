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
  
  @IBOutlet weak var map: MKMapView!
  var myRoute : MKRoute?
  var isBlue = false
  
  var polyFinal = MKPolyline()
  
  var route:MKRoute! = MKRoute()
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.\
    self.map.delegate = self
    
    
    var filePath = NSBundle.mainBundle().pathForResource("directions",ofType:"json")
    
    
    var data = NSData(contentsOfFile:filePath!)
    
    do
    {
      let arr = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
      print(arr)
      
      var arrayCoordinates = [CLLocationCoordinate2D]()
      for item in arr as! NSArray
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
    }
    catch
    {
      print(error)
    }
    
    isBlue = true
    //    filePath = NSBundle.mainBundle().pathForResource("directions copy",ofType:"json")
    //
    //
    //    data = NSData(contentsOfFile:filePath!)
    //
    //    do
    //    {
    //      let arr = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
    //      print(arr)
    //
    //      for item in arr as! NSArray
    //      {
    //        print(item)
    //        let start = item["start_location"] as! NSDictionary
    //        let end = item["end_location"] as! NSDictionary
    //
    //        let point1 = MKPointAnnotation()
    //        let point2 = MKPointAnnotation()
    //
    //        if let lat = start["lat"],lng = start["lng"],eLat = end["lat"],eLng = end["lng"]
    //        {
    //          print(lat)
    //          print(lng)
    //          point1.coordinate = CLLocationCoordinate2DMake(lat as! Double,lng as! Double)
    //          point1.title = "Taipei"
    //          point1.subtitle = "Taiwan"
    //          //        map.addAnnotation(point1)
    //
    //          point2.coordinate = CLLocationCoordinate2DMake(eLat as! Double,eLng as! Double)
    //          point2.title = "Chungli"
    //          point2.subtitle = "Taiwan"
    //          //        map.addAnnotation(point2)
    //          map.centerCoordinate = point2.coordinate
    //          map.delegate = self
    //
    //          //Span of the map
    //          map.setRegion(MKCoordinateRegionMake(point2.coordinate, MKCoordinateSpanMake(0.7,0.7)), animated: true)
    //
    //          let directionsRequest = MKDirectionsRequest()
    //          let markTaipei = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point1.coordinate.latitude, point1.coordinate.longitude), addressDictionary: nil)
    //          let markChungli = MKPlacemark(coordinate: CLLocationCoordinate2DMake(point2.coordinate.latitude, point2.coordinate.longitude), addressDictionary: nil)
    //
    //          directionsRequest.source = MKMapItem(placemark: markChungli)
    //          directionsRequest.destination = MKMapItem(placemark: markTaipei)
    //          directionsRequest.transportType = MKDirectionsTransportType.Automobile
    //          let directions = MKDirections(request: directionsRequest)
    //          directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
    //            if error == nil {
    //              self.myRoute = response!.routes[0]
    //              self.map.addOverlay((self.myRoute?.polyline)!)
    //            }
    //          }
    //        }
    //
    //      }
    //    }
    //    catch
    //    {
    //      print(error)
    //    }
    
    
    
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
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

