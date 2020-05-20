//
//  ActivityData.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


enum Activity: String, Codable, CaseIterable {
  case unknown = ""
  case stationary = "stationary"
  case walking = "walking"
  case running = "running"
  case automotive = "automotive"
  case cycling = "cycling"
}

struct ActivityData: Codable {
  var timestamp: String
  var activity: Activity
  var confidence: Int
  
  enum CodingKeys: String, CodingKey {
    case timestamp
    case activity =  "movement"
    case confidence
  }
  
  init(timestamp: String = "",
       activity: Activity = .unknown,
       confidence: Int = 0) {
    self.timestamp = timestamp
    self.activity = activity
    self.confidence = confidence
  }
  
  var description: String {
    var msg = timestamp + ","
    msg = msg + activity.rawValue + ","
    msg = msg + confidence.description + "\n"
    return msg
  }
}

struct ActivityDataAll: Codable {
  var activity: [ActivityData]
  
  enum CodingKeys: String, CodingKey {
    case activity = "activity"
  }
}
