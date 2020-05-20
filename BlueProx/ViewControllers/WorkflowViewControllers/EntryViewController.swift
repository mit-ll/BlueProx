//
//  EntryViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {
  
  // MARK: Properties
  
  // MARK: UIProperties
  
  @IBOutlet weak var runScenarioButton: UIButton!
  @IBOutlet weak var runLiveDetectorButton: UIButton!
  @IBOutlet weak var infoHelpButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    
    UIDevice.current.isProximityMonitoringEnabled = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
  }
  
  // MARK: UI Methods
  func setupUI() {
    runScenarioButton.setupRoundedButton()
    runLiveDetectorButton.setupRoundedButton()
    infoHelpButton.setupRoundedButton()
  }
  
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.destination is EngineeringSettingsViewController {
      _ = segue.destination as? EngineeringSettingsViewController
    }
  }
  
  
  @IBAction func sessionDoneButton_TouchUpInside(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .began:
      break
    case .changed:
      break
    case .ended:
      print("Long press ended at \(sender.location(in: sender.view))")
      self.performSegue(withIdentifier: "EngineeringSettingsViewController", sender: self)
    case .cancelled:
      break
    case .failed, .possible:
      break
    }
    
  }
}
