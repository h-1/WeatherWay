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
class ViewController: UIViewController {
  
  //Outlets
  @IBOutlet weak var butLetsGo: UIButton!
  @IBOutlet weak var map: MKMapView!
  @IBOutlet weak var seg: UISegmentedControl!
  @IBOutlet weak var lblDrivingTime: UILabel!
  @IBOutlet weak var lblETA: UILabel!
  @IBOutlet weak var lblDistance: UILabel!

  //Variables
  var myRoute : MKRoute?
  var isBlue = false
  var polyFinal = MKPolyline()
  var route:MKRoute! = MKRoute()
  var directions = [[NSDictionary]]()
  var directionsBest = [NSDictionary]()
  var directionsGoogle = [NSDictionary]()

  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.\
    self.map.delegate = self
    
    self.directionsBest = self.directions[0]
    self.directionsGoogle = self.directions[1]
    
    print("directions:\(directions)")
  }
  func showInfo(directions:[NSDictionary])
  {
    //Show on the map
    var arrayCoordinates = self.appendAllDirections(directions)
    self.showDirectionsOnMap(arrayCoordinates)
    
    //Round corner button
    self.butLetsGo.layer.cornerRadius = 10 // this value vary as per your desire
    self.butLetsGo.clipsToBounds = true
    
    //Driving Time Label
    var time = self.getTotalTime(directions)
    time = time/60
    self.lblDrivingTime.text = "\(time) minutes"
    
    //ETA Label
    self.lblETA.text = self.getETA(Double(self.getTotalTime(directions)))
    
    //Distance Label
    self.lblDistance.text = "\(self.getTotalMiles(directions)) miles"    
  }
  
  //MARK: - Common Funcions
  
  //Returns total time of the trip (In Seconds)
  func getTotalTime(directions:[NSDictionary]) -> Int
  {
    var totalTime = 0
    for step in directions
    {
      let time = (step["duration"]as! NSDictionary)["value"] as! Int
      totalTime = totalTime + time
    }
    return totalTime
  }
  
  //Returns total miles of the trip
  func getTotalMiles(directions:[NSDictionary]) -> Int
  {
    var totalMeters = 0
    for step in directions
    {
      let distance = (step["distance"]as! NSDictionary)["value"] as! Int
      totalMeters = totalMeters + distance
    }
    
    //Convert to miles
    let totalMiles = Double(totalMeters) * 0.0006213711922373339
    return Int(totalMiles)
  }
  
  //Returns ETA in hh:mm PM based on total time
  func getETA(totalTime:NSTimeInterval) -> String
  {
    let date = NSDate(timeIntervalSinceNow: totalTime)
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "hh:mm a"
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    
    let dateValue = dateFormatter.stringFromDate(date)
    return dateValue

  }

  //Shows array of Coordinates on map as a Polyline
  func showDirectionsOnMap(var directions:[CLLocationCoordinate2D])
  {
    let poly = MKPolyline(coordinates: &directions, count: directions.count)
    self.polyFinal = poly
    self.map.insertOverlay(poly, atIndex: 0)
  }
  
  //Parses all directions from google in a single array
  func appendAllDirections(directions: [NSDictionary]) -> [CLLocationCoordinate2D]
  {
    var arrayCoordinates = [CLLocationCoordinate2D]()
    for item in directions
    {
      print(item)
      let start = item["start_location"] as! NSDictionary
      let end = item["end_location"] as! NSDictionary
      
      if let lat = start["lat"],lng = start["lng"],eLat = end["lat"],eLng = end["lng"]
      {
        let coordinateS = CLLocationCoordinate2D(latitude: (lat as? Double)!, longitude: (lng as? Double)!)
        let coordinateE = CLLocationCoordinate2D(latitude: (eLat as? Double)!, longitude: (eLng as? Double)!)
        arrayCoordinates.append(coordinateS)
        arrayCoordinates.append(coordinateE)
      }
    }
    return arrayCoordinates
  }
  
  //MARK: - Segmented
  //Segmented between Best route(0) and Google Route (1)
  @IBAction func segChanged(sender: AnyObject)
  {
    switch self.seg.selectedSegmentIndex
    {
    case 0:
      //Best
      self.showInfo(self.directionsBest)
      break
    case 1:
      //Google
      self.showInfo(self.directionsGoogle)

      break
    default:
      break;
    }
  }
}

//MARK: - MKMapViewDelegate
extension ViewController:MKMapViewDelegate
{
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer
  {
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

