//
//  DeviceSetupViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit

class DeviceSetupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  
  
  // MARK: Properties
  
  var roleSelected: String = "Beacon"

  // NOTE: Residual - was here to select from Android or iPhone
  fileprivate let phoneMakePickerView = ToolbarPickerView()
  var phoneMakePickerData: [String] = []
  private var phoneMakeSelected: String = "iPhone"

  var originalSessionID: String = ""
  var userID: String = ""
  
  // Carried over from type and scenario choice,
  // propogated to this VC.
  var typeSelected: TestType = TestType.structured
  var scenarioSelected: ScenarioModel = ScenarioModel()
  var environmentSelected: Environment? = nil
  
  // For user entry - Structured and Freeform
  var beaconPartnerDeviceInfo: DeviceInfo = DeviceInfo()
  var receiverSelfDeviceInfo: DeviceInfo = DeviceInfo()
  var metaData: MetaData = MetaData()

  var beaconSubjectInfo: ScenarioModel = ScenarioModel()
  
  // iPhone
  fileprivate let applePhonePickerView = ToolbarPickerView()
  var applePhonePickerData: [String] = []
  private var applePhones: [ApplePhone] = []
  private var applePhoneSelected: String = ""
  
  // On body location
  fileprivate let onBodyLocationPickerView = ToolbarPickerView()
  var onBodyLocationPickerData: [String] = []
  private var onBodyLocations: [OnBodyLocation] = []
  private var onBodyLocationSelected: String = ""
  
  // Pose
  fileprivate let subjectPosePickerView = ToolbarPickerView()
  var subjectPosePickerData: [String] = []
  private var subjectPoses: [SubjectPose] = []
  private var subjectPoseSelected: String = ""

  @IBOutlet weak var roleLabel: UILabel!
  @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
  @IBOutlet weak var userIDLabel: UILabel!
  @IBOutlet weak var userIDTextField: UITextField!
  
  @IBOutlet weak var otherDeviceLabel: UILabel!
  @IBOutlet weak var deviceModelTextField: UITextField!
  @IBOutlet weak var modelLabel: UILabel!
  
  @IBOutlet weak var onBodyLocationLabel: UILabel!
  @IBOutlet weak var onBodyLocationTextField: UITextField!
  
  @IBOutlet weak var subjectPoseLabel: UILabel!
  @IBOutlet weak var subjectPoseTextField: UITextField!
  
  @IBOutlet weak var nextButton: UIButton!
  
  
  // MARK: UIView overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UIDevice.current.isProximityMonitoringEnabled = false

    originalSessionID = Utility.getSessionID()

    self.userIDTextField.delegate = self
    self.deviceModelTextField.delegate = self

    phoneMakePickerData = PhoneMake.allCases.map { $0.rawValue }
    createPhoneMakePickerView()
 
    fixSegmentedControliOSBug()
    
    // iPhonePickerView
    deviceModelTextField.delegate = self
    applePhonePickerData = ApplePhone.allCases.map { $0.rawValue }
    createPickerView(textField: self.deviceModelTextField,
                     toolbarPickerView: self.applePhonePickerView)

    // On body location
    onBodyLocationTextField.delegate = self
    onBodyLocationPickerData = OnBodyLocation.allCases.map { $0.rawValue }
    createPickerView(textField: self.onBodyLocationTextField,
                     toolbarPickerView: self.onBodyLocationPickerView)

    // Subject Pose
    subjectPoseTextField.delegate = self
    subjectPosePickerData = SubjectPose.allCases.map { $0.rawValue }
    if typeSelected != TestType.situational {
      subjectPosePickerData = subjectPosePickerData.filter { $0 != "walking" }
    }
    createPickerView(textField: self.subjectPoseTextField,
                     toolbarPickerView: self.subjectPosePickerView)
    
    // Init UI display
    initUI()
    initMoveViewWithKeyboard()
  }
  
  func fixSegmentedControliOSBug() {
    if #available(iOS 13.0, *) {
      roleSegmentedControl.backgroundColor = UIColor.darkGray  // black
      roleSegmentedControl.layer.borderColor = UIColor.white.cgColor
      roleSegmentedControl.selectedSegmentTintColor = UIColor.white
      roleSegmentedControl.layer.borderWidth = 1
      
      let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
      roleSegmentedControl.setTitleTextAttributes(titleTextAttributes, for:.normal)
      
      let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: UIColor.black]
      roleSegmentedControl.setTitleTextAttributes(titleTextAttributes1, for:.selected)
    }
  }
  
  
  // MARK: Picker view related - Conform to UIPickerView
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    var count = 0
    if pickerView == phoneMakePickerView {
      count = phoneMakePickerData.count
    } else if pickerView == onBodyLocationPickerView {
      count = onBodyLocationPickerData.count
    } else if pickerView == subjectPosePickerView {
      count = subjectPosePickerData.count
    } else if pickerView == applePhonePickerView {
      count = applePhonePickerData.count
    }
    return count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    var msg = ""
    if pickerView == phoneMakePickerView {
      msg = phoneMakePickerData[row]
    } else if pickerView == onBodyLocationPickerView {
      msg = onBodyLocationPickerData[row]
    } else if pickerView == subjectPosePickerView {
      msg = subjectPosePickerData[row]
    } else if pickerView == applePhonePickerView {
      msg = applePhonePickerData[row]
    }
    
    return msg
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView == phoneMakePickerView {
      phoneMakeSelected = phoneMakePickerData[row]
      //      populateMetaData()
    } else if pickerView == onBodyLocationPickerView {
      onBodyLocationSelected = onBodyLocationPickerData[row]
      onBodyLocationTextField.text = onBodyLocationSelected
    } else if pickerView == subjectPosePickerView {
      subjectPoseSelected = subjectPosePickerData[row]
      subjectPoseTextField.text = subjectPoseSelected
    } else if pickerView == applePhonePickerView {
      applePhoneSelected = applePhonePickerData[row]
      deviceModelTextField.text = applePhoneSelected
    }
  }
  
  // MARK: UITextField Methods
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    textField.text = ""
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == userIDTextField {
      nextButton.isEnabled = false
    }
    return true
  }
  
  func allRequiredItemsAreFilled() -> Bool {
    var isOK = false
    switch typeSelected {
    case .none:
      assert(false, "DEVELOPER - test type of none is invalid.")
    case .structured:
      fallthrough
    case .situational:
      fallthrough
    case .free_form:
      isOK = ((deviceModelTextField.text != "") &&
        (onBodyLocationTextField.text != "") &&
        (subjectPoseTextField.text != ""))
    }
    return isOK
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == userIDTextField {
      self.nextButton.isEnabled = true
      if let idEntered = textField.text {
        self.userID = idEntered
      }
    }
    
    if allRequiredItemsAreFilled() {
      self.nextButton.isEnabled = true
    } else {
      self.nextButton.isEnabled = false
    }
  }
  
  
  // MARK: UITextView Methods
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    textView.text = ""
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.destination is TestRunDetailSetupViewController {
      let vc = segue.destination as? TestRunDetailSetupViewController
      vc?.scenarioSelected = self.scenarioSelected
      vc?.metaData = self.metaData
      vc?.roleSelected = self.roleSelected
      vc?.beaconSubjectInfo = self.beaconSubjectInfo
    } else if segue.destination is BeaconOnViewController {
      _ = segue.destination as? BeaconOnViewController
    }
  }
  
  
  // MARK: Methods
  
  func initUI() {
    nextButton.isEnabled = false
    nextButton.setupRoundedButton()
    
    switch typeSelected {
    case .structured:
      fallthrough
    case .free_form:
      showSegmentedControl()
      hideAllExceptRole()
      nextButton.isEnabled = true
    case .situational:
      assert(false, "DEVELOPER - Should not enter DeviceSetupVC for situational.")
    case .none:
      assert(false, "DEVELOPER - test type .none invalid")
    }
  }
  
  func hideSegmentedControl() {
    roleLabel.isHidden = true
    roleSegmentedControl.isHidden = true
  }
  
  func showSegmentedControl() {
    roleLabel.isHidden = false
    roleSegmentedControl.isHidden = false
  }
  
  func hideAllExceptRole() {
    userIDLabel.isHidden = true
    userIDTextField.isHidden = true
    otherDeviceLabel.isHidden = true
    deviceModelTextField.isHidden = true
    modelLabel.isHidden = true
    onBodyLocationLabel.isHidden = true
    subjectPoseLabel.isHidden = true
    onBodyLocationTextField.isHidden = true
    subjectPoseTextField.isHidden = true
  }
  
  func showAllExceptRole() {
    userIDLabel.isHidden = false
    userIDTextField.isHidden = false
    otherDeviceLabel.isHidden = false
    deviceModelTextField.isHidden = false
    modelLabel.isHidden = false
    onBodyLocationLabel.isHidden = false
    subjectPoseLabel.isHidden = false
    onBodyLocationTextField.isHidden = false
    subjectPoseTextField.isHidden = false
  }
  
  func updateLabels() {
    
    switch typeSelected {
    case .structured:
      fallthrough
    case .free_form:
      break
    case .situational:
      assert(false, "DEVELOPER - Should not enter DeviceSetupVC for situational.")
    case .none:
      assert(false, "DEVELOPER - test type .none invalid")
    }
  }
  
  func updateStructuredAndFreeformDeviceInfo() {
    if roleSelected == "Beacon" {
      // Beacon auto finds
      // Receiver takes from form
      receiverSelfDeviceInfo.codeVersion = "VERSION XX"
      receiverSelfDeviceInfo.model = deviceModelTextField.text ?? ""
      
      beaconPartnerDeviceInfo.codeVersion = "VERSION XX"
      beaconPartnerDeviceInfo.make = UIDevice.modelName
      beaconPartnerDeviceInfo.model = UIDevice.current.name
      
    } else if roleSelected == "Receiver" {
      // Receiver auto finds
      // Beacon takes from form
      beaconPartnerDeviceInfo.codeVersion = "VERSION XX"
      beaconPartnerDeviceInfo.model = deviceModelTextField.text ?? ""
      
      receiverSelfDeviceInfo.codeVersion = "VERSION XX"
      receiverSelfDeviceInfo.make = UIDevice.modelName
      receiverSelfDeviceInfo.model = UIDevice.current.name
    }
  }
  
  func updateSituationalDeviceInfo() {
    // NOTE: "Partner" reuses receiverDeviceInfo data structure
    if roleSelected == "Partner" {
      receiverSelfDeviceInfo.codeVersion = "VERSION XX"
      receiverSelfDeviceInfo.model = deviceModelTextField.text ?? ""
      
      beaconPartnerDeviceInfo.codeVersion = "VERSION XX"
      beaconPartnerDeviceInfo.make = UIDevice.modelName
      beaconPartnerDeviceInfo.model = UIDevice.current.name
      
    } else if roleSelected == "Self" {
      // Receiver auto finds
      // Beacon takes from form
      beaconPartnerDeviceInfo.codeVersion = "VERSION XX"
      beaconPartnerDeviceInfo.model = deviceModelTextField.text ?? ""
      
      receiverSelfDeviceInfo.codeVersion = "VERSION XX"
      receiverSelfDeviceInfo.make = UIDevice.modelName
      receiverSelfDeviceInfo.model = UIDevice.current.name
    }
  }
  
  func updateDeviceInfo() {
    
    switch typeSelected {
    case .structured:
      updateStructuredAndFreeformDeviceInfo()
    case .situational:
      updateSituationalDeviceInfo()
    case .free_form:
      updateStructuredAndFreeformDeviceInfo()
    case .none:
      assert(false, "DEVELOPER - test type .none is invalid")
      
    }
  }
  
  func updateBeaconSubjectInfo() {
    beaconSubjectInfo = ScenarioModel(scenario: scenarioSelected)
    beaconSubjectInfo.onBodyLocation = OnBodyLocation(rawValue: onBodyLocationTextField.text!) ?? OnBodyLocation.unknown
    beaconSubjectInfo.subjectPose = SubjectPose(rawValue: subjectPoseTextField.text!) ?? SubjectPose.unknown
  }
  
  // MARK: UI Methods
  
  func createPhoneMakePickerView() {
    self.phoneMakePickerView.dataSource = self
    self.phoneMakePickerView.delegate = self
    self.phoneMakePickerView.toolbarDelegate = self
    
    self.phoneMakePickerView.reloadAllComponents()
  }
  
  func createPickerView(textField: UITextField, toolbarPickerView: ToolbarPickerView) {
    textField.inputView = toolbarPickerView
    textField.inputAccessoryView = toolbarPickerView.toolbar
    
    toolbarPickerView.dataSource = self
    toolbarPickerView.delegate = self
    toolbarPickerView.toolbarDelegate = self
    
    toolbarPickerView.selectedRow(inComponent: 0)
    toolbarPickerView.reloadAllComponents()
  }

  
  // MARK: Actions
  
  @objc func tapDone(sender: Any) {
    self.view.endEditing(true)
  }
  
  @IBAction func roleSegmentedControl_ValueChanged(_ sender: UISegmentedControl) {
    switch roleSegmentedControl.selectedSegmentIndex {
    case 0:
      roleSelected = "Beacon"
      hideAllExceptRole()
      nextButton.isEnabled = true
    case 1:
      roleSelected = "Receiver"
      showAllExceptRole()
      updateDeviceInfo()
      if allRequiredItemsAreFilled() {
        self.nextButton.isEnabled = true
      } else {
        self.nextButton.isEnabled = false
      }
    default:
      break
    }
    
    UIDevice.current.isProximityMonitoringEnabled = false
  }
  
  @IBAction func nextButton_TouchUpInside(_ sender: UIButton) {
    updateDeviceInfo()
    let sessionID = Utility.getSessionID()
    self.metaData = MetaData(
      sessionId: sessionID,
      userId: userID,
      selfUserId: "",
      partnerTester: beaconPartnerDeviceInfo,
      selfTester: receiverSelfDeviceInfo)
    
    updateBeaconSubjectInfo()

    if roleSelected == "Receiver" {
      self.performSegue(withIdentifier: "StructuredSituationalSetupViewController", sender: self)
    } else if roleSelected == "Beacon" {
      self.performSegue(withIdentifier: "BeaconOnViewController", sender: self)
    }
  }

}

extension DeviceSetupViewController: ToolbarPickerViewDelegate {
  
  func didTapDone(_ sender: UIPickerView) {
    var row = self.phoneMakePickerView.selectedRow(inComponent: 0)
    self.phoneMakePickerView.selectRow(row, inComponent: 0, animated: false)
    
    row = self.onBodyLocationPickerView.selectedRow(inComponent: 0)
    self.onBodyLocationPickerView.selectRow(row, inComponent: 0, animated: false)
    self.onBodyLocationTextField.resignFirstResponder()
    
    row = self.subjectPosePickerView.selectedRow(inComponent: 0)
    self.subjectPosePickerView.selectRow(row, inComponent: 0, animated: false)
    self.subjectPoseTextField.resignFirstResponder()

    row = self.applePhonePickerView.selectedRow(inComponent: 0)
    self.applePhonePickerView.selectRow(row, inComponent: 0, animated: false)
    self.deviceModelTextField.resignFirstResponder()
  }
  
  func didTapCancel(_ sender: UIPickerView) {
    if sender == onBodyLocationPickerView {
      self.onBodyLocationTextField.text = nil
      self.onBodyLocationTextField.resignFirstResponder()
      } else if sender == subjectPosePickerView {
        self.subjectPoseTextField.text = nil
        self.subjectPoseTextField.resignFirstResponder()
      } else if sender == applePhonePickerView {
        self.deviceModelTextField.text = nil
        self.deviceModelTextField.resignFirstResponder()
    }
  }
}
