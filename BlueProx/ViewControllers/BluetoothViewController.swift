//
//  BluetoothViewController.swift
//  BluetoothProximity
//
//  Created by Michael Wentz on 4/11/20.
//  Copyright © 2020 Michael Wentz. All rights reserved.
//

import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController, CBPeripheralManagerDelegate {
    
    // -----------------------------------------------------------------------------
    // Advertiser related
    // -----------------------------------------------------------------------------
    
    // Members
    var service: CBMutableService!
    var advertiser: CBPeripheralManager!
    
    // Text input for the name, with functions to enable/disable input
    @IBOutlet weak var adNameInput: UITextField!
    @IBAction func newAdNameInput(_ sender: Any) {
        print("New advertisement name: " + adNameInput.text!)
    }
    func enableAdNameInput() {
        adNameInput.isEnabled = true
        adNameInput.backgroundColor = UIColor.white
    }
    func disableAdNameInput() {
        adNameInput.isEnabled = false
        adNameInput.backgroundColor = UIColor.lightGray
    }
    
    // Dismiss keyboard when touching elsewhere on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // MJW 4/11: never enable adNameInput - always use a unique name for the app.
    // Advertiser enable switch. The input name cannot be changed when advertising is on.
    @IBOutlet weak var adSwitch: UISwitch!
    @IBAction func adSwitchChanged(_ sender: Any) {
        if adSwitch.isOn {
            //disableAdNameInput()
            startAdvertising()
            print("Started advertising")
        } else {
            stopAdvertising()
            //enableAdNameInput()
            print("Stopped advertising")
        }
    }
    
    // If moved to foreground and we're currently advertising, cycle it
    @objc func movedToForeground() {
        if adSwitch.isOn {
            stopAdvertising()
            startAdvertising()
            print("Moved to foreground, cycled advertising")
        }
    }
    
    // If moved to background and we're currently advertising, cycle it
    @objc func movedToBackground() {
        if adSwitch.isOn {
            stopAdvertising()
            startAdvertising()
            print("Moved to background, cycled advertising")
        }
    }
    
    // Only enable the advertiser switch when Bluetooth is enabled
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            adSwitch.isEnabled = true
        } else {
            adSwitch.isEnabled = false
        }
    }
    
    // Adds service and stops advertising
    func startAdvertising() {
        advertiser.removeAllServices()
        advertiser.add(service)
        let adData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [service.uuid],
            CBAdvertisementDataLocalNameKey: adNameInput.text!
        ]
        advertiser.stopAdvertising()
        advertiser.startAdvertising(adData)
    }
    
    // Stops advertising and removes service
    func stopAdvertising() {
        advertiser.stopAdvertising()
    }
    
    // -----------------------------------------------------------------------------
    // Scanner related
    // -----------------------------------------------------------------------------
    
    // Scanner enable switch
    @IBOutlet weak var scanSwitch: UISwitch!
    @IBAction func scanSwitchChanged(_ sender: Any) {
        if scanSwitch.isOn {
            //startScanning()
            print("Started scanning")
        } else {
            //stopScanning()
            print("Stopped scanning")
        }
    }
    
    // -----------------------------------------------------------------------------
    // General operation
    // -----------------------------------------------------------------------------
    
    // Make top navigation bar black with white text
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MJW 4/11: we can also detect the lock state, but only while in this app. See here:
        // https://stackoverflow.com/questions/39764263/detect-screen-unlock-events-in-ios-swift
        // Testing this on device, when locked we continue advertising, but as soon as the
        // screen is turned on again, the advertised name goes away until the device is unlocked
        // and this app is back open. If you lock the device, and unlock without this app in
        // the foreground, it will not start advertising again! We'll need to make sure the
        // users keep this app open while collecting data.
        
        // Register helpers to detect if the application is in the foreground or background
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(movedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(movedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // MJW 4/11: never enable adNameInput - always use a unique name for the app.
        // Set input name to the device name
        //adNameInput.text = UIDevice.current.name
        disableAdNameInput()
        
        // Create a service
        let serviceUUID: String = "FF2450D9-D9FC-4717-9E36-3A765FEDE097"
        let serviceCBUUID = CBUUID(string: serviceUUID)
        service = CBMutableService(type: serviceCBUUID, primary: true)
        
        // Initialize advertiser. This will prompt the user to enable Bluetooth if needed
        advertiser = CBPeripheralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
}
