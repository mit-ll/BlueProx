//
//  BluetoothData.swift
//  BlueProx
//

import Foundation


struct BluetoothData: Codable {
  let timestamp: String
  let uuid: String
  let rssi: Int
  let advName: String
  let advPower: Double
  let advTime: Double
  
  enum CodingKeys: String, CodingKey {
    case timestamp
    case uuid
    case rssi
    case advName = "name"
    case advPower = "tx_power"
    case advTime = "adv_time"
  }
  
  var description: String {
    var msg = timestamp + ","
    msg = msg + uuid + ","
    msg = msg + rssi.description + ","
    msg = msg + advName + ","
    msg = msg + advPower.description + ","
    msg = msg + advTime.description + "\n"
    return msg
  }
}


struct BluetoothDataAll: Codable {
  var bluetooth: [BluetoothData]
  
  enum CodingKeys: String, CodingKey {
    case bluetooth = "bluetooth"
  }
}
