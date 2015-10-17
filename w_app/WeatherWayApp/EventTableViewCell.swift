//
//  EventTableViewCell.swift
//  WeatherWayApp
//
//  Created by Lucas Farah on 10/17/15.
//  Copyright © 2015 Lucas Farah. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

  @IBOutlet weak var imgvEvent: UIImageView!
  @IBOutlet weak var lblTitleEvent: UILabel!
  @IBOutlet weak var lblTimeEvent: UILabel!
  @IBOutlet weak var lblAddressEvent: UILabel!
  
  
  
  
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
