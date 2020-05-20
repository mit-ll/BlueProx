//
//  CombinedData.swift
//  BluetoothProximity
//


// Combined data
struct CombinedData: Codable {
  var schema_ver: String
  var schema_name: String
  var appData: AppData
  var sessionData: SessionData
  
  var scenarioSettings: ScenarioModel
  var accel: [AccelerometerData]
  var gyro: [GyroscopeData]
  var prox: [ProximityData]
  var attitude: [AttitudeData]
  
  var pedometer: [PedometerData]
  var altitude: [AltitudeData]

  var activity: [ActivityData]
  var heading: [HeadingData]
  
  var dictionary: [String : Any] {
    return [
      "scenario_settings": scenarioSettings,
      "accel": accel,
      "gyro": gyro,
      "prox": prox,
      "attitude": attitude,
      
      "pedometer": pedometer,
      "altitude": altitude,
      
      "activity": activity,
      "heading": heading]
  }
  
  enum CodingKeys: String, CodingKey {
    case scenarioSettings = "scenario_settings"
    case accel = "accel"
    case gyro = "gyro"
    case prox = "prox"
    case attitude = "attitude"
    
    case pedometer = "pedometer"
    case altitude = "altitude"
    
    case activity = "activity"
    case heading = "heading"
  }
  
}

struct CombinedDataTagged: Codable {
  var combinedData: CombinedData
  
  var dictionary: [String : Any] {
    return ["data": combinedData]
  }
  
  enum CodingKeys: String, CodingKey {
    case combinedData = "data"
  }
}

