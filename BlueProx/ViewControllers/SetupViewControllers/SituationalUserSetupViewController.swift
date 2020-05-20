//
//  SituationalUserSetupViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit


class SituationalUserSetupViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

  
  // MARK: Properties
  
  var roleSelected: String = "Partner"
  var sessionID: String = ""
  var userID: String = ""
  var selfUserID: String = ""
  
  // Carried over from type and scenario choice,
  // propogated to this VC.
  var typeSelected: TestType = TestType.structured
  var scenarioSelected: ScenarioModel = ScenarioModel()
  var environmentSelected: Environment? = nil
  var metaData: MetaData = MetaData()
  var partnerDeviceInfo: DeviceInfo = DeviceInfo()
  var partnerScenarioInfo: ScenarioModel = ScenarioModel()
  var selfDeviceInfo: DeviceInfo = DeviceInfo()
  var selfScenarioInfo: ScenarioModel = ScenarioModel()

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
  
  // Environment
  var envType: EnvironmentType = EnvironmentType.unknown
  var envDetail:EnvironmentDetail = EnvironmentDetail.unknown
  fileprivate let environmentPickerView = ToolbarPickerView()
  var environmentPickerData: [[String]] = [[String]]()
  private var environments: [Environment] = []
  
  fileprivate let environmentTypePickerView = ToolbarPickerView()
  var environmentTypePickerData: [String] = []
  private var environmentTypes: [EnvironmentType] = []
  private var environmentTypesSelected: String = ""
  
  fileprivate let environmentDetailPickerView = ToolbarPickerView()
  var environmentDetailPickerData: [String] = []
  private var environmentDetails: [EnvironmentDetail] = []
  private var environmentDetailsSelected: String = ""
  
  
  // MARK: UI Properties
  
  @IBOutlet weak var headingLabel: UILabel!
  @IBOutlet weak var instructionLabel: UILabel!
  @IBOutlet weak var userIDLabel: UILabel!
  @IBOutlet weak var userIDTextField: UITextField!
  @IBOutlet weak var deviceModelTextField: UITextField!
  @IBOutlet weak var onBodyLocationTextField: UITextField!
  @IBOutlet weak var subjectPoseTextField: UITextField!
  @IBOutlet weak var environmentTextField: UITextField!
  @IBOutlet weak var nextButton: UIButton!
  
  @IBOutlet weak var userIdLabel: UILabel!
  @IBOutlet weak var deviceModelLabel: UILabel!
  @IBOutlet weak var onBodyLocationLabel: UILabel!
  @IBOutlet weak var poseLabel: UILabel!
  @IBOutlet weak var environmentLabel: UILabel!
  
  
  // MARK: UIView overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sessionID = Utility.getSessionID()

    self.userIDTextField.delegate = self

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
      subjectPosePickerData = subjectPosePickerData.filter { $0 == "walking" }
    }
    createPickerView(textField: self.subjectPoseTextField,
                     toolbarPickerView: self.subjectPosePickerView)
    
    // Environment
    initEnvironment()
    
    // Init UI display
    initUI()
    initMoveViewWithKeyboard()
    
    // Update from data passed in
    updatePartnerSelfScenarioBasic()
  }
  
  func updatePartnerSelfScenarioBasic() {
    partnerScenarioInfo.name = scenarioSelected.name
    partnerScenarioInfo.type = scenarioSelected.type
    partnerScenarioInfo.summary = scenarioSelected.summary
    partnerScenarioInfo.testDurationMinutes = scenarioSelected.testDurationMinutes
    partnerScenarioInfo.loopDurationSeconds = scenarioSelected.loopDurationSeconds
    partnerScenarioInfo.partnerLocations = scenarioSelected.partnerLocations
    partnerScenarioInfo.selfLocations = scenarioSelected.selfLocations
    partnerScenarioInfo.subjectAngles = scenarioSelected.subjectAngles
    
    selfScenarioInfo.name = scenarioSelected.name
    selfScenarioInfo.type = scenarioSelected.type
    selfScenarioInfo.summary = scenarioSelected.summary
    selfScenarioInfo.testDurationMinutes = scenarioSelected.testDurationMinutes
    selfScenarioInfo.loopDurationSeconds = scenarioSelected.loopDurationSeconds
    selfScenarioInfo.partnerLocations = scenarioSelected.partnerLocations
    selfScenarioInfo.selfLocations = scenarioSelected.selfLocations
    selfScenarioInfo.subjectAngles = scenarioSelected.subjectAngles
  }

  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  // MARK: Initialize objects
  func initEnvironment() {
    // Environment
    environmentTextField.delegate = self
    environmentPickerData = [[String]]()
    environmentTypePickerData = EnvironmentType.allCases.map { $0.rawValue }
    environmentDetailPickerData = EnvironmentDetail.allCases.map { $0.rawValue }
    environmentPickerData.append(environmentTypePickerData)
    environmentPickerData.append(environmentDetailPickerData)
    createPickerView(textField: self.environmentTextField,
                     toolbarPickerView: self.environmentPickerView)
  }

  // MARK: Picker view related - Conform to UIPickerView
  
  // Change size of text in picker view
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    var title = UILabel()
    var font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.regular)
    if pickerView == environmentPickerView {
      font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
    }
    if let view = view {
      title = view as! UILabel
    }
    title.font = font
    title.textColor = UIColor.black
    pickerView.backgroundColor = UIColor.lightGray
    
    if pickerView == environmentPickerView {
      title.text =  environmentPickerData[component][row]
    } else if pickerView == onBodyLocationPickerView {
      title.text =  onBodyLocationPickerData[row]
    } else if pickerView == subjectPosePickerView {
      title.text =  subjectPosePickerData[row]
    } else if pickerView == applePhonePickerView {
      title.text =  applePhonePickerData[row]
    }
    
    title.textAlignment = .center
    
    return title
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    if pickerView == environmentPickerView {
      return 2
    } else {
      return 1
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    var count = 0
    if pickerView == onBodyLocationPickerView {
      count = onBodyLocationPickerData.count
    } else if pickerView == subjectPosePickerView {
      count = subjectPosePickerData.count
    } else if pickerView == applePhonePickerView {
      count = applePhonePickerData.count
    } else if pickerView == environmentPickerView {
      count = environmentPickerData[component].count
    }
    return count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    var msg = ""
    if pickerView == onBodyLocationPickerView {
      msg = onBodyLocationPickerData[row]
    } else if pickerView == subjectPosePickerView {
      msg = subjectPosePickerData[row]
    } else if pickerView == applePhonePickerView {
      msg = applePhonePickerData[row]
    } else if pickerView == environmentPickerView {
      msg = environmentPickerData[component][row]
    }
    
    return msg
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
    if pickerView == environmentPickerView {
      switch component {
      case 0:
        envType = EnvironmentType(rawValue: environmentPickerData[0][row])!
      case 1:
        envDetail = EnvironmentDetail(rawValue: environmentPickerData[1][row])!
      default:
        break
      }
      let env = Environment(envType: envType, envDetail: envDetail)
      environmentSelected = env
      environmentTextField.text = environmentSelected?.shortDescription
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
    case .situational:
      if roleSelected == "Partner" {
        isOK = (deviceModelTextField.text != "") &&
          (onBodyLocationTextField.text != "") &&
          (subjectPoseTextField.text != "")
      } else if roleSelected == "Self" {
        isOK = (environmentSelected?.envType.rawValue != "") &&
          (environmentSelected?.envDetail.rawValue != "") &&
          (environmentTextField.text != "") &&
          (onBodyLocationTextField.text != "") &&
          (subjectPoseTextField.text != "")
      }
    case .structured:
      fallthrough
    case .free_form:
      fallthrough
    case .none:
      assert(false, "DEVELOPER - test type of none is invalid.")
    }
    return isOK
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == userIDTextField {
      if let idEntered = textField.text {
        if roleSelected == "Partner" {
          self.userID = idEntered
        } else if roleSelected == "Self" {
          self.selfUserID = idEntered
        }
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
    if segue.identifier == "SituationalSegueToSelf" {
      let vc = segue.destination as? SituationalUserSetupViewController
      vc?.scenarioSelected = self.scenarioSelected
      vc?.typeSelected = self.typeSelected

      // First time into the SituationalUserSetupViewController,
      // role is Partner
      vc?.roleSelected = "Self"
      vc?.userID = self.userID
      vc?.selfUserID = self.selfUserID
      vc?.metaData = self.metaData
      vc?.partnerDeviceInfo = self.partnerDeviceInfo
      vc?.partnerScenarioInfo = self.partnerScenarioInfo
    }
    
    
    if segue.identifier == "DataCollectionSetupViewController" {
      let vc = segue.destination as? DataCollectionSetupViewController
      vc?.typeSelected = self.typeSelected
      vc?.scenarioSelected = self.scenarioSelected
      vc?.metaData = self.metaData
      vc?.partnerScenarioInfo = self.partnerScenarioInfo
      vc?.selfScenarioInfo = self.selfScenarioInfo
    }
  }
  
  
  // MARK: Methods
  
  func initUI() {
    nextButton.isEnabled = false
    nextButton.setupRoundedButton()

    if typeSelected != TestType.situational {
      assert(false, "DEVELOPER - should not have reached this VC. It is reserved for situational test type only")
    }
    
    if roleSelected == "Partner" {
      headingLabel.text = "Partner User Info"
      instructionLabel.text = "Enter information about your partner's setup."
      
      showPartnerExceptRole()
      
    } else if roleSelected == "Self" {
      headingLabel.text = "Self User Info"
      instructionLabel.text = "Enter information about your own setup."
      
      showSelfExceptRole()
    }
  }
  
  func hideAllExceptRole() {
    userIDLabel.isHidden = true
    deviceModelLabel.isHidden = true
    onBodyLocationLabel.isHidden = true
    poseLabel.isHidden = true
    environmentLabel.isHidden = true
    
    userIDTextField.isHidden = true
    deviceModelTextField.isHidden = true
    onBodyLocationTextField.isHidden = true
    subjectPoseTextField.isHidden = true
    environmentTextField.isHidden = true
  }
  
  func showAllExceptRole() {
    userIDLabel.isHidden = false
    deviceModelLabel.isHidden = false
    onBodyLocationLabel.isHidden = false
    poseLabel.isHidden = false
    environmentLabel.isHidden = false
    
    userIDTextField.isHidden = false
    deviceModelTextField.isHidden = false
    onBodyLocationTextField.isHidden = false
    subjectPoseTextField.isHidden = false
    environmentTextField.isHidden = false
  }
  
  func showSelfExceptRole() {
    showAllExceptRole()
    deviceModelLabel.isHidden = true
    deviceModelTextField.isHidden = true
    
    userIDLabel.text = "My User ID (Optional)"
    onBodyLocationLabel.text = "My On Body Location"
    poseLabel.text = "My Test Pose"
    environmentLabel.text = "My Environment"
  }
  
  func showPartnerExceptRole() {
    showAllExceptRole()
    environmentLabel.isHidden = true
    environmentTextField.isHidden = true
    
    userIDLabel.text = "Partner User ID (Optional)"
    deviceModelLabel.text = "Parter Device Model"
    onBodyLocationLabel.text = "Partner On Body Location"
    poseLabel.text = "Partner Test Pose"
    environmentLabel.text = "Partner Environment"
  }
  
  func updateUserInfo() {
    if roleSelected == "Partner" {
      // Update information about your partner
      let partnerDevInfo = DeviceInfo(
        codeVersion: Bundle.main.fullVersionBuildNumber ?? "",
        phoneUuid: "",
        make: deviceModelTextField.text ?? "",
        model: "",
        os: "",
        notes: "")
      metaData = MetaData(
        sessionId: Utility.getSessionID(),
        userId: userIDTextField.text ?? "",
        selfUserId: "",
        partnerTester: partnerDevInfo,
        selfTester: DeviceInfo())
      
      // Partner Meta data
      metaData.userId = self.userID
      
      // Partner Device Info
      partnerDeviceInfo.model = deviceModelTextField.text!
      
      // Partner scenario info
      partnerScenarioInfo.onBodyLocation = OnBodyLocation(rawValue: onBodyLocationTextField.text!)!
      partnerScenarioInfo.subjectPose = SubjectPose(rawValue: subjectPoseTextField.text!)!
      
    } else if roleSelected == "Self" {
      metaData.selfUserId = userIDTextField.text!
      selfDeviceInfo.codeVersion = Bundle.main.fullVersionBuildNumber ?? ""
      // NOTE: We could also capture the friendly name of the phone, ie: iPhoneStacy: UIDevice.current.name
      selfDeviceInfo.model = UIDevice.modelName
      selfScenarioInfo.onBodyLocation = OnBodyLocation(rawValue: onBodyLocationTextField.text!)!
      selfScenarioInfo.subjectPose = SubjectPose(rawValue: subjectPoseTextField.text!)!
            
      let selfDevInfo = DeviceInfo(
        codeVersion: Bundle.main.fullVersionBuildNumber ?? "",
        phoneUuid: "",
        make: deviceModelTextField.text ?? "",
        model: UIDevice.modelName,
        os: "",
        notes: "")
      metaData = MetaData(
        sessionId: Utility.getSessionID(),
        userId: self.userID,
        selfUserId: userIDTextField.text ?? "",
        partnerTester: self.partnerDeviceInfo,
        selfTester: selfDevInfo)
            
      var env = Environment()
      if let envValueCsv = environmentTextField.text {
        let envArr = envValueCsv.components(separatedBy: ", ")
        if envArr.count == 2 {
          env.envType = EnvironmentType(rawValue: envArr[0])!
          env.envDetail = EnvironmentDetail(rawValue: envArr[1])!
        }
      }
      self.selfScenarioInfo.environmentType = env.envType
      self.selfScenarioInfo.environmentDetail = env.envDetail
    }
  }

  
  // MARK: UI Methods
  
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
  
  @IBAction func nextButton_TouchUpInside(_ sender: UIButton) {
    updateUserInfo()
      if roleSelected == "Partner" {
      self.performSegue(withIdentifier: "SituationalSegueToSelf", sender: self)
    } else if roleSelected == "Self" {
      self.performSegue(withIdentifier: "DataCollectionSetupViewController", sender: self)
    }
  }

}

extension SituationalUserSetupViewController: ToolbarPickerViewDelegate {
  
  func didTapDone(_ sender: UIPickerView) {
    var row = 0
    switch sender {
    case onBodyLocationPickerView:
      row = self.onBodyLocationPickerView.selectedRow(inComponent: 0)
      self.onBodyLocationPickerView.selectRow(row, inComponent: 0, animated: false)
      self.onBodyLocationTextField.resignFirstResponder()
      
    case subjectPosePickerView:
      row = self.subjectPosePickerView.selectedRow(inComponent: 0)
      self.subjectPosePickerView.selectRow(row, inComponent: 0, animated: false)
      self.subjectPoseTextField.resignFirstResponder()
      
    case applePhonePickerView:
      row = self.applePhonePickerView.selectedRow(inComponent: 0)
      self.applePhonePickerView.selectRow(row, inComponent: 0, animated: false)
      self.deviceModelTextField.resignFirstResponder()
      
    case environmentPickerView:
      row = self.environmentPickerView.selectedRow(inComponent: 0)
      self.environmentPickerView.selectRow(row, inComponent: 0, animated: false)
      self.environmentTextField.resignFirstResponder()
      
    default:
      break
    }
  }
  
  func didTapCancel(_ sender: UIPickerView) {
    if sender == onBodyLocationPickerView {
      self.onBodyLocationTextField.text = nil
      self.onBodyLocationTextField.resignFirstResponder()
    } else if sender == environmentPickerView {
      self.environmentTextField.text = nil
      self.environmentTextField.resignFirstResponder()
    } else if sender == subjectPosePickerView {
      self.subjectPoseTextField.text = nil
      self.subjectPoseTextField.resignFirstResponder()
    } else if sender == applePhonePickerView {
      self.deviceModelTextField.text = nil
      self.deviceModelTextField.resignFirstResponder()
    }
  }
}

