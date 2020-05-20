//
//  ProximityData.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


struct LiveViewData: Codable {
  var uuid: String
  var name: String
  var rssi: Int
  var proximity: String
  
  enum CodingKeys: String, CodingKey {
    case uuid
    case name
    case rssi
    case proximity
  }
  
  var description: String {
    var msg = ""
    msg = msg + uuid + ","
    msg = msg + name + ","
    msg = msg + rssi.description + ","
    msg = msg + proximity + "\n"
    return msg
  }
  
}

