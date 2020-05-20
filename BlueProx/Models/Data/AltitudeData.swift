//
//  AltitudeData.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation

struct AltitudeData: Codable {
    let timestamp: String
    let altitude: Double
    let pressure: Double

    enum CodingKeys: String, CodingKey {
        case timestamp
        case altitude = "altitude_m"
        case pressure = "pressure_kPa"
    }
    
    var description: String {
        var msg = timestamp + ","
        msg += altitude.description + ","
        msg += pressure.description + "\n"
        return msg
    }
}

struct AltitudeDataAll: Codable {
    var altitude: [AltitudeData]
    
    enum CodingKeys: String, CodingKey {
        case altitude = "barometer"
    }
}
