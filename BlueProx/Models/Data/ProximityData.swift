//
//  ProximityData.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


struct ProximityData: Codable {
  let timestamp: String
  let state: Int
  
  enum CodingKeys: String, CodingKey {
    case timestamp
    case state
  }
  
  var description: String {
    var msg = timestamp + ","
    msg = msg + state.description + "\n"
    return msg
  }
}

struct ProximityDataAll: Codable {
  var prox: [ProximityData]
  
  enum CodingKeys: String, CodingKey {
    case prox = "prox"
  }
}
