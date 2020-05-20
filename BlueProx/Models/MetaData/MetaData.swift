//
//  MetaData.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


struct MetaData: Codable {
  var sessionId: String
  var userId: String
  var selfUserId: String
  let partnerTester: DeviceInfo
  let selfTester: DeviceInfo

  enum CodingKeys: String, CodingKey {
    case sessionId = "session_id"
    case userId = "user_id"
    case selfUserId = "self_user_id"
    case partnerTester = "partner_tester"
    case selfTester = "self_tester"
  }
  
  init(
   sessionId: String,
   userId: String,
   selfUserId: String,
   partnerTester: DeviceInfo,
   selfTester: DeviceInfo) {
    self.sessionId = sessionId
    self.userId = userId
    self.selfUserId = selfUserId
    self.partnerTester = partnerTester
    self.selfTester = selfTester
  }
  
  init() {
    self.sessionId = ""
    self.userId = ""
    self.selfUserId = ""
    self.partnerTester = DeviceInfo()
    self.selfTester = DeviceInfo()
  }
  
  var loggerDescription: String {
    var msg = "session_id," + sessionId + "\n"
    msg = msg + Utility.getTimestamp() + "," + "user_id, " + userId + "\n"
    msg = msg + Utility.getTimestamp() + "," + "self_user_id, " + selfUserId + "\n"
    msg = msg + Utility.getTimestamp() + "," + "partner_tester, " + partnerTester.loggerDescription + "\n"
    msg = msg + Utility.getTimestamp() + "," + "self_tester, " + selfTester.loggerDescription
    return msg
  }
  
}

struct MetaDataTagged: Codable {
  var metaData: MetaData
  
  var dictionary: [String : Any] {
    return ["meta_data": metaData]
  }
  
  enum CodingKeys: String, CodingKey {
    case metaData = "meta_data"
  }
}
