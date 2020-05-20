//
//  HeadingData.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation

struct HeadingData: Codable {
    let timestamp: String
    let trueHeading: Double
    let magneticHeading: Double
    let accuracy: Double
    let x: Double
    let y: Double
    let z: Double
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case trueHeading
        case magneticHeading
        case accuracy
        case x
        case y
        case z
    }
    
    var description: String {
        var msg = timestamp + ","
        msg += trueHeading.description + ","
        msg += magneticHeading.description + ","
        msg += accuracy.description + ","
        msg += x.description + ","
        msg += y.description + ","
        msg += z.description + "\n"
        return msg
    }
}

struct HeadingDataAll: Codable {
    var heading: [HeadingData]
    
    enum CodingKeys: String, CodingKey {
        case heading = "heading"
    }
}
