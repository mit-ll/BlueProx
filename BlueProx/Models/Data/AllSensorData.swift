//
//  AllSensorData.swift
//  BlueProx
//


// All sensor data
struct AllSensorData: Codable {
  var accel: [AccelerometerData]
  var activity: [ActivityData]
  var altitude: [AltitudeData]  // NOTE: Same as barometer
  var bluetooth: [BluetoothData]
  var gravity: [GravityData]
  var gyro: [GyroscopeData]
  var heading: [HeadingData]
  var magField: [MagFieldData]
  var orientation: [OrientationData]
  var pedometer: [PedometerData]
  var prox: [ProximityData]

  var dictionary: [String : Any] {
    return [
      "accel": accel,
      "activity": activity,
      "altitude": altitude,
      "bluetooth": bluetooth,
      "gravity": gravity,
      "gyro": gyro,
      "heading": heading,
      "magField": magField,
      "orientation": orientation,
      "pedometer": pedometer,
      "prox": prox
    ]
  }
  
  enum CodingKeys: String, CodingKey {
    case accel = "accel_raw"
    case activity = "activity"
    case altitude = "barometer"
    case bluetooth = "bluetooth"
    case gravity = "accel_gravity"
    case gyro = "gyro"
    case heading = "heading"
    case magField = "magnetic_field"
    case orientation = "orientation"
    case pedometer = "pedometer"
    case prox = "prox"
  }
  
  init() {
    self.accel = []
    self.activity = []
    self.altitude = []
    self.bluetooth = []
    self.gravity = []
    self.gyro = []
    self.heading = []
    self.magField = []
    self.orientation = []
    self.pedometer = []
    self.prox = []
  }
  
  init(
    accel: [AccelerometerData],
    activity: [ActivityData],
    altitude: [AltitudeData],
    bluetooth: [BluetoothData],
    gravity: [GravityData],
    gyro: [GyroscopeData],
    heading: [HeadingData],
    magField: [MagFieldData],
    orientation: [OrientationData],
    pedometer: [PedometerData],
    prox: [ProximityData]
  ) {
    self.accel = accel
    self.activity = activity
    self.altitude = altitude
    self.bluetooth = bluetooth
    self.gravity = gravity
    self.gyro = gyro
    self.heading = heading
    self.magField = magField
    self.orientation = orientation
    self.pedometer = pedometer
    self.prox = prox
  }
  
}


