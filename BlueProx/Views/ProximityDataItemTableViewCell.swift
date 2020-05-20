//
//  ProximityDataItemTableViewCell.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit


class ProximityDataItemTableViewCell: UITableViewCell {

  // MARK: Properties
  
  @IBOutlet weak var uuidLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var rssiLabel: UILabel!
  @IBOutlet weak var proximityLabel: UILabel!
  
  
  // MARK: UITableViewCell Overrides
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
