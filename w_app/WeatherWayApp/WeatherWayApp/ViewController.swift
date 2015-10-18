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

  //Variables
  var myRoute : MKRoute?
  var isBlue = false
  var polyFinal = MKPolyline()
  var route:MKRoute! = MKRoute()
  var directions = [NSDictionary]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.\
    self.map.delegate = self
    
    print("directions:\(directions)")
    
    //Show on the map
    var arrayCoordinates = self.appendAllDirections(directions)
    self.showDirectionsOnMap(arrayCoordinates)
    
    
    //Round corner button
    self.butLetsGo.layer.cornerRadius = 10 // this value vary as per your desire
    self.butLetsGo.clipsToBounds = true
  }
  
  //MARK: - Common Funcions
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
      //do something
      
      break
    case 1:
      //do something else
      
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

