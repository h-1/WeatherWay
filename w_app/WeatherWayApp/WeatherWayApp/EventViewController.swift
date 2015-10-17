//
//  EventViewController.swift
//  WeatherWayApp
//
//  Created by Lucas Farah on 10/11/15.
//  Copyright © 2015 Lucas Farah. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

class EventViewController: UIViewController {
  let eventStore = EKEventStore()
  
  @IBOutlet weak var table: UITableView!
  
  var arrEvents = [EKEvent]()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.fetchEvents()
  }
  
  //Fetches first event available
  func fetchEvents() {
    eventStore.requestAccessToEntityType(.Event) { (ii, oo) -> Void in
      let cale = self.eventStore.calendarsForEntityType(EKEntityType.Event)
      let date = NSDate(timeIntervalSinceNow:0)
      
      let endDate = NSDate(timeIntervalSinceNow: 604800*10);   //This is 10 weeks in seconds
      let predicate = self.eventStore.predicateForEventsWithStartDate(date, endDate: NSDate(), calendars: cale)
      let events = self.eventStore.eventsMatchingPredicate(predicate)
      let event = events[0]
      self.arrEvents.append(event)
      let loc = CalendarController()
      print("Title: \(event.title)")
      print("Location: \(event.location)")
      print("startDate: \(event.startDate)")
      
      let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
      dispatch_async(dispatch_get_global_queue(priority, 0)) {
        // do some task
        dispatch_async(dispatch_get_main_queue()) {
          // update some UI
          // Obtain a configured MFMessageComposeViewController
          self.table.reloadData()
        }
      }
      
    }
  }
  
  
}

//MARK: - UITableviewDataSource
extension EventViewController:UITableViewDataSource
{
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return self.arrEvents.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    var cell = tableView.dequeueReusableCellWithIdentifier("cell") as! EventTableViewCell!
    if !(cell != nil)
    {
      cell = EventTableViewCell(style:.Default, reuseIdentifier: "cell")
    }
    let event = self.arrEvents[indexPath.row]
    
    // setup cell without force unwrapping it
    cell.lblTitleEvent.text = event.title
    cell.lblAddressEvent.text = event.location
    
    //Time
    let date = event.startDate
    cell.lblTimeEvent.text = "at " + self.getStringForDate(date)
    return cell
  }
  
  //Converts and formats NSDate to "October 20, 2015"
  func getStringForDate(date: NSDate) -> String
  {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "hh:mm a"
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    
    let dateValue = dateFormatter.stringFromDate(date)
    return dateValue
  }
}

//MARK: - UITableviewDelegate
extension EventViewController:UITableViewDelegate
{
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.performSegueWithIdentifier("eventSelected", sender: self.arrEvents[indexPath.row])
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let theDestination = (segue.destinationViewController as! LoadingViewController)
    let event = sender
    theDestination.event = event as! EKEvent
  }
}


