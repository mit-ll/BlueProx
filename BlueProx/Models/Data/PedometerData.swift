//
//  StepData.swift
//  BlueProx
//

import Foundation

struct PedometerData: Codable {
    let timestamp: String
    let step: Int
    let dist: Double
    let pace: Double
    let cadence: Double
    let floorsAsc: Double
    let floorsDesc: Double
    
    enum CodingKeys: String, CodingKey {
        case timestamp
        case step
        case dist
        case pace
        case cadence
        case floorsAsc
        case floorsDesc
    }
    
    var description: String {
        var msg = timestamp + ","
        msg += step.description + ","
        msg += dist.description + ","
        msg += pace.description + ","
        msg += cadence.description + ","
        msg += floorsAsc.description + ","
        msg += floorsDesc.description + ","
        return msg
    }
}

struct PedometerDataAll: Codable {
    var step: [PedometerData]
    
    enum CodingKeys: String, CodingKey {
        case step = "pedometer"
    }
}
