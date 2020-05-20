//
//  Sensors.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation


// Manages sensors (other than Bluetooth) and logs their data
class Sensors: NSObject {
  
  // MARK: Properties
  
  // Objects
  var engSettings: RoleSettings!
  var logger: Logger!
  var motion = CMMotionManager()
  var activity = CMMotionActivityManager()
  var location = CLLocationManager()
  var pedometer = CMPedometer()
  var altimeter = CMAltimeter()
  
  // Data containers
  var accelData: AccelerometerDataAll = AccelerometerDataAll(accel: [])
  var pedometerData: PedometerDataAll = PedometerDataAll(step: [])
  var proxData: ProximityDataAll = ProximityDataAll(prox: [])
  var magFieldData: MagFieldDataAll = MagFieldDataAll(magField: [])
  var gravityData:GravityDataAll = GravityDataAll(gravity: [])
  var orientationData: OrientationDataAll = OrientationDataAll(orientation: [])
  var gyroData: GyroscopeDataAll = GyroscopeDataAll(gyro: [])
  var activityData: ActivityDataAll = ActivityDataAll(activity: [])
  var headingData: HeadingDataAll = HeadingDataAll(heading: [])
  var altitudeData: AltitudeDataAll = AltitudeDataAll(altitude: [])

    
  // MARK: Initializers
  
  override init() {
    
    // Get logger
    let delegate = UIApplication.shared.delegate as! AppDelegate
    engSettings = delegate.engSettings
    logger = delegate.logger

    super.init()
  }
  
  // MARK: Methods
  
  func resetData() {
    accelData.accel = []
    pedometerData.step = []
    proxData.prox = []
    magFieldData.magField = []
    gravityData.gravity = []
    orientationData.orientation = []
    gyroData.gyro = []
    activityData.activity = []
    headingData.heading = []
    altitudeData.altitude = []
  }
  
  // Start sensors
  func start(settings: EngineeringSettings) {
    resetData()
    
    if settings.sensorsEnabledDict[SensorType.proximity] == true {
      startProximity()
    }
    if settings.sensorsEnabledDict[SensorType.accelerometer] == true {
      startAccelerometer()
    }
    if settings.sensorsEnabledDict[SensorType.gyroscope] == true {
      startGyroscope()
    }
    if settings.sensorsEnabledDict[SensorType.attitude] == true {
      startAttitude()
    }
    if settings.sensorsEnabledDict[SensorType.activity] == true {
      startActivity()
    }
    if settings.sensorsEnabledDict[SensorType.heading] == true {
      startHeading()
    }
    if settings.sensorsEnabledDict[SensorType.pedometer] == true {
      startPedometer()
    }
    if settings.sensorsEnabledDict[SensorType.altimeter] == true {
      startAltimeter()
    }
  }
  
  // Stop sensors
  func stop() {
    stopProximity()
    stopAccelerometer()
    stopGyroscope()
    stopAttitude()
    stopActivity()
    stopHeading()
    stopPedometer()
    stopAltimeter()
  }
  
  // ---------------------------------------------------------------------------
  // Proximity sensor
  // ---------------------------------------------------------------------------
  
  // Starts proximity sensor
  func startProximity() {
    let device = UIDevice.current
    device.isProximityMonitoringEnabled = true
    if device.isProximityMonitoringEnabled {
      NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged(notification:)), name: NSNotification.Name(rawValue: "UIDeviceProximityStateDidChangeNotification"), object: device)
    }
  }
  
  // Stops proximity sensor
  func stopProximity() {
    let device = UIDevice.current
    device.isProximityMonitoringEnabled = true
    if device.isProximityMonitoringEnabled {
      NotificationCenter.default.removeObserver(self)
    }
  }
  
  // Called when the proximity sensor is activated
  @objc func proximityChanged(notification: NSNotification) {
    let state = UIDevice.current.proximityState ? 1 : 0
    let timestamp = Utility.getTimestamp()
    
    let s = "Proximity,\(state)"
    logger.write(s)
    
    let currentProxData = ProximityData(timestamp: timestamp, state: state)
    proxData.prox.append(currentProxData)
    
  }
  
  // ---------------------------------------------------------------------------
  // Accelerometer
  // ---------------------------------------------------------------------------
  
  // Poll frequency and timer
  var accelRateHz = 4.0
  var accelTimer: Timer?
  
  // Starts the accelerometer
  private func startAccelerometer() {
    motion.accelerometerUpdateInterval = (1.0/accelRateHz)
    motion.startAccelerometerUpdates()
    accelTimer = Timer.scheduledTimer(timeInterval: (1.0/accelRateHz), target: self, selector: #selector(newAccelData), userInfo: nil, repeats: true)
  }
  
  // Stops the accelerometer
  private func stopAccelerometer() {
    accelTimer?.invalidate()
    accelTimer = nil
  }
  
  // Called when there is new accelerometer data
  @objc func newAccelData() {
    let data = motion.accelerometerData
    let accelX = data?.acceleration.x
    let accelY = data?.acceleration.y
    let accelZ = data?.acceleration.z
    if let x = accelX, let y = accelY, let z = accelZ {
      let timestamp = Utility.getTimestamp()

      let s = "Accelerometer,\(x),\(y),\(z)"
      logger.write(s)
      
      let currentAccelData = AccelerometerData(timestamp: timestamp, x: x, y: y, z: z)
      accelData.accel.append(currentAccelData)
    }
  }
  
  // ---------------------------------------------------------------------------
  // Gyroscope
  // ---------------------------------------------------------------------------
  
  // Poll frequency and timer
  var gyroRateHz = 4.0
  var gyroTimer: Timer?
  
  // Starts the gyroscope
  private func startGyroscope() {
    motion.gyroUpdateInterval = (1.0/gyroRateHz)
    motion.startGyroUpdates()
    gyroTimer = Timer.scheduledTimer(timeInterval: (1.0/gyroRateHz), target: self, selector: #selector(newGyroData), userInfo: nil, repeats: true)
  }
  
  // Stops the gyroscope
  private func stopGyroscope() {
    gyroTimer?.invalidate()
    gyroTimer = nil
  }
  
  // Called when there is new gyroscope data
  @objc func newGyroData() {
    let data = motion.gyroData
    let rotX = data?.rotationRate.x
    let rotY = data?.rotationRate.y
    let rotZ = data?.rotationRate.z
    if let x = rotX, let y = rotY, let z = rotZ {
      let timestamp = Utility.getTimestamp()
      let s = "Gyroscope,\(x),\(y),\(z)"
      logger.write(s)
      
      let currentGyroData = GyroscopeData(timestamp: timestamp, x: x, y: y, z: z)
      gyroData.gyro.append(currentGyroData)
    }
  }
    
  // ---------------------------------------------------------------------------
  // Attitude
  // ---------------------------------------------------------------------------

  // Poll frequency and timer
  var attitudeRateHz = 4.0
  var attitudeTimer: Timer?

  private func startAttitude() {
    guard motion.isDeviceMotionAvailable else {
        print("motion not available")
        return
    }
    motion.deviceMotionUpdateInterval = 1.0 / attitudeRateHz
    motion.showsDeviceMovementDisplay = true
    motion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
    attitudeTimer = Timer.scheduledTimer(timeInterval: (1.0 / attitudeRateHz), target: self, selector: #selector(newAttitudeData), userInfo: nil, repeats: true)
  }

  @objc func newAttitudeData() {
    guard let data = self.motion.deviceMotion else { return }

    let timestamp = Utility.getTimestamp()
    let pitch = data.attitude.pitch
    let roll = data.attitude.roll
    let yaw = data.attitude.yaw
    self.logger.write("Attitude,\(pitch),\(roll),\(yaw)")

    let x = data.gravity.x
    let y = data.gravity.y
    let z = data.gravity.z
    self.logger.write("Gravity,\(x),\(y),\(z)")
    
    let accuracy = data.magneticField.accuracy
    let mfieldx = data.magneticField.field.x
    let mfieldy = data.magneticField.field.y
    let mfieldz = data.magneticField.field.z
    var s = "Magnetic-field,\(mfieldx),\(mfieldy),\(mfieldz)"
    switch accuracy {
    case .uncalibrated:
        s = s + ",uncalibrated"
    case .low:
        s = s + ",low"
    case .medium:
        s = s + ",medium"
    case .high:
      s = s + ",high"
    }
    self.logger.write(s)
    
    let currentOrientationData = OrientationData(
      timestamp: timestamp,
      pitch: pitch,
      roll: roll,
      yaw: yaw)
    let currentGravityData = GravityData(
      timestamp: timestamp,
      gx: x,
      gy: y,
      gz: z)
    let currentMagFieldData = MagFieldData(
      timestamp: timestamp,
      mfieldx: mfieldx,
      mfieldy: mfieldy,
      mfieldz: mfieldz,
      mfieldaccuracy: accuracy.rawValue)
    
    orientationData.orientation.append(currentOrientationData)
    gravityData.gravity.append(currentGravityData)
    magFieldData.magField.append(currentMagFieldData)
  }
  
  private func stopAttitude() {
    attitudeTimer?.invalidate()
    attitudeTimer = nil
  }
    
  // -----------------------------------------------------------------------------
  // Activities
  // -----------------------------------------------------------------------------
  private func getActivity(activityStatus: CMMotionActivity) -> Activity {
    var activity: Activity = .unknown
    if activityStatus.stationary == true {
      activity = .stationary
    } else if activityStatus.walking {
      activity = .walking
    } else if activityStatus.running {
      activity = .running
    } else if activityStatus.automotive {
      activity = .automotive
    } else if activityStatus.cycling {
      activity = .cycling
    } else if activityStatus.unknown {
      activity = .unknown
    }
    return activity
  }
  
  private func startActivity() {
    activity.startActivityUpdates(to: OperationQueue.main) {
      [weak self] (activityStatus: CMMotionActivity?) in
      guard let activityStatus = activityStatus else { return }
      DispatchQueue.main.async {
        let timestamp = Utility.getTimestamp()
        let activityFound: Activity = self!.getActivity(activityStatus: activityStatus)

        let s = "Activity,\(activityStatus.timestamp),\(activityFound.rawValue),\(activityStatus.confidence.rawValue)"
        self?.logger.write(s)
        
        let currentActivityData = ActivityData(
          timestamp: timestamp,
          activity: activityFound,
          confidence: activityStatus.confidence.rawValue)
        
        self?.activityData.activity.append(currentActivityData)
      }
    }
  }
       
  private func stopActivity() {
    activity.stopActivityUpdates()
  }
    
  // ---------------------------------------------------------------------------
  // Heading
  // ---------------------------------------------------------------------------

  var headingResolution = 5.0 // degress

  private func startHeading() {
    location.delegate = self
    location.headingFilter = headingResolution
    location.requestWhenInUseAuthorization()
    location.startUpdatingHeading()
  }
  
  private func stopHeading() {
    location.stopUpdatingHeading()
  }

  // ---------------------------------------------------------------------------
  // Pedometer
  // ---------------------------------------------------------------------------

  private func startPedometer() {
    if CMPedometer.isStepCountingAvailable() {
        pedometer.startUpdates(from: Date()) { (data, error) in
            if let data = data {
                let timestamp = Utility.getTimestamp()
                let step = data.numberOfSteps.intValue
                let dist = data.distance?.doubleValue ?? 0
                let pace = data.currentPace?.doubleValue ?? 0
                let cadence = data.currentCadence?.doubleValue ?? 0
                let floorsAsc = data.floorsAscended?.doubleValue ?? 0
                let floorsDesc = data.floorsDescended?.doubleValue ?? 0
                let s = "Pedometer,\(step),\(dist),\(pace),\(cadence),\(floorsAsc),\(floorsDesc)"
                self.logger.write(s)
                
                let currentStepData = PedometerData(timestamp: timestamp, step: step, dist: dist, pace: pace, cadence: cadence, floorsAsc: floorsAsc, floorsDesc: floorsDesc)
                self.pedometerData.step.append(currentStepData)
            }
        }
    }
  }
  
  private func stopPedometer() {
    pedometer.stopUpdates()
  }

  // ---------------------------------------------------------------------------
  // Altimeter
  // ---------------------------------------------------------------------------

  private func startAltimeter() {
    if CMAltimeter.isRelativeAltitudeAvailable() {
        altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) {
            [weak self] (data, error) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                let timestamp = Utility.getTimestamp()
                let altitude = data.relativeAltitude as! Double
                let pressure = data.pressure as! Double
                let s = "Altitude,\(altitude),\(pressure)"
                self?.logger.write(s)

                let currentAltitudeData = AltitudeData(timestamp: timestamp, altitude: altitude, pressure: pressure)
                self?.altitudeData.altitude.append(currentAltitudeData)
            }
        }
    }
  }
      
  private func stopAltimeter() {
    altimeter.stopRelativeAltitudeUpdates()
  }
}

extension Sensors: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let timestamp = Utility.getTimestamp()
        let trueHeading = newHeading.trueHeading
        let magneticHeading = newHeading.magneticHeading
        let accuracy = newHeading.headingAccuracy
        let x = newHeading.x
        let y = newHeading.y
        let z = newHeading.z
        let s = "Heading,\(trueHeading),\(magneticHeading),\(accuracy),\(x),\(y),\(z)"
        self.logger.write(s)

        let currentHeading = HeadingData(timestamp: timestamp, trueHeading: trueHeading, magneticHeading: magneticHeading, accuracy: accuracy, x: x, y: y, z: z)
        headingData.heading.append(currentHeading)
    }
}
