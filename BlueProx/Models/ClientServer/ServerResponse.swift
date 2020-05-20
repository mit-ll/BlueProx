//
//  ServerResponse.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


struct ServerResponse: Codable {
  let message: String
  let status: Int
  
  
  enum CodingKeys: String, CodingKey {
    case message
    case status
  }
  
  var description: String {
    var msg = message + ","
    msg = msg + status.description + "\n"
    return msg
  }
}
