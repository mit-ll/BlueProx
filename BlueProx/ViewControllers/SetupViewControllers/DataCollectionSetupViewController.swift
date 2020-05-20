//
//  DataCollectionSetupViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit


enum DataSendMethod {
  case mitllEmail
  case mitllServer
  case userEmail
}


class DataCollectionSetupViewController: UIViewController, UITextFieldDelegate {
  
  // MARK: Properties
  
  // Passed in
  var typeSelected: TestType = TestType.none
  var scenarioSelected: ScenarioModel = ScenarioModel()
  var metaData: MetaData = MetaData()
  var partnerScenarioInfo: ScenarioModel = ScenarioModel()
  var selfScenarioInfo: ScenarioModel = ScenarioModel()
  
  // To propagate
  var dataSendMethods: [DataSendMethod] = []
  var userEmail: String = ""
  
  
  // UI Properties
  @IBOutlet weak var mitllEmailButton: CheckBox!
  @IBOutlet weak var mitllServerButton: CheckBox!
  @IBOutlet weak var userEmailButton: CheckBox!
  @IBOutlet weak var userEmailTextField: UITextField!
  @IBOutlet weak var nextButton: UIButton!
  
  
  // MARK: UIViewController Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initUI()
    
    initDataCollectionUI()
    
    // Put this in all configuration setup view
    // controllers
    initMoveViewWithKeyboard()
    
    if isRequiredAndValidSendMethod() {
      nextButton.isEnabled = true
    } else {
      nextButton.isEnabled = false
    }
  }
  
  
  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PerformSituationalTest" {
      print("SITUATIONAL")
      let vc = segue.destination as? FreeFormTestViewController
      vc?.typeSelected = self.typeSelected
      vc?.scenarioSelected = self.scenarioSelected
      vc?.metaData = self.metaData
      vc?.partnerScenarioInfo = self.partnerScenarioInfo
      vc?.selfScenarioInfo = self.selfScenarioInfo
      vc?.dataSendMethods = self.dataSendMethods
      vc?.userEmail = self.userEmail
    }
  }
  
  
  // MARK: UI Related Methods
  
  func initUI() {
    nextButton.isEnabled = false
    nextButton.setupRoundedButton()
  }
  
  func initDataCollectionUI() {
    userEmailTextField.delegate = self
    
    mitllEmailButton.addTarget(self, action: #selector(onCheckBoxValueChange(_:)), for: .valueChanged)
    mitllServerButton.addTarget(self, action: #selector(onCheckBoxValueChange(_:)), for: .valueChanged)
    userEmailButton.addTarget(self, action: #selector(onCheckBoxValueChange(_:)), for: .valueChanged)
    
    userEmailTextField.isEnabled = false
    
    mitllEmailButton.isChecked = true
    mitllServerButton.isChecked = true
  }
  
  @objc func onCheckBoxValueChange(_ sender: CheckBox) {
    if sender == userEmailButton {
      userEmailTextField.isEnabled = userEmailButton.isChecked
      if userEmailButton.isChecked == false {
        userEmailTextField.text = ""
      }
    }

    if isRequiredAndValidSendMethod() {
      nextButton.isEnabled = true
    } else {
      nextButton.isEnabled = false
    }
  }
  
  
  // MARK: Methods
  
  func updateDataSendMethods() {
    dataSendMethods.removeAll()
    if mitllEmailButton.isChecked {
      dataSendMethods.append(.mitllEmail)
    }
    if mitllServerButton.isChecked {
      dataSendMethods.append(.mitllServer)
    }
    if userEmailButton.isChecked {
      dataSendMethods.append(.userEmail)
    }
  }
  
  // Check boxes
  
  func isRequiredAndValidSendMethod() -> Bool {
    let atLeastOneSendMethodChecked = (mitllEmailButton.isChecked || userEmailButton.isChecked || mitllServerButton.isChecked)
    if userEmailButton.isChecked {
      // is the text entry valid?
      let em = userEmailTextField.text ?? ""
      if em.isValidEmail() {
        return true
      } else {
        return false
      }
    }
    return atLeastOneSendMethodChecked
  }
  
  
  // MARK: Actions
  
  @IBAction func userEmailButton_TouchUpInside(_ sender: CheckBox) {
    userEmailTextField.isEnabled = userEmailButton.isChecked
  }
  
  @IBAction func nextButton_TouchUpIndside(_ sender: Any) {
    updateDataSendMethods()
    userEmail = userEmailTextField.text ?? ""
    
    // NOTE: For now this VC only segues to FreeForm
    self.performSegue(withIdentifier: "PerformSituationalTest", sender: self)
  }
  
  // MARK: Conform to UITextField
  
  // Dismiss keyboard when touching outside of keyboard/entry area
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
    super.touchesBegan(touches, with: event)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    print("[textFieldShouldReturn]")
    if textField == userEmailTextField {
      self.userEmail = userEmailTextField.text ?? ""
      self.userEmailTextField.resignFirstResponder()
    }
    return true
  }
  
  // Disable editing the text fields (only allow changing from the pickers)
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == userEmailTextField {
      nextButton.isEnabled = false
    }
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == userEmailTextField {
      let em = userEmailTextField.text ?? ""
      if em.isValidEmail() {
        print("[textFieldDidEndEditing] email OK")
        self.userEmail = em
        userEmailTextField.layer.borderWidth = 1
        userEmailTextField.layer.borderColor = UIColor.gray.cgColor
        userEmailTextField.layer.cornerRadius = 5
        
        // self.nextButton.isEnabled = allRequiredTextFieldsAreFilled() ? true : false
      } else {
        print("[textFieldDidEndEditing] Invalid email")
        userEmailTextField.text = ""
        userEmailTextField.layer.borderWidth = 2
        userEmailTextField.layer.borderColor = UIColor.red.cgColor
        userEmailTextField.layer.cornerRadius = 5
        self.nextButton.isEnabled = false
      }
    }
    
    // if (allRequiredTextFieldsAreFilled() &&
    if isRequiredAndValidSendMethod() {
      nextButton.isEnabled = true
    } else {
      nextButton.isEnabled = false
    }
  }
}
