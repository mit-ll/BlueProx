//
//  StructuredSituationalSetupViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit


class TestRunDetailSetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
  
  
  // MARK: Properties
  
  // Propogated from scenario selection
  var typeSelected: TestType = TestType.structured
  var scenarioSelected: ScenarioModel = ScenarioModel()
  var metaData: MetaData  = MetaData()
  var roleSelected: String = ""
  var beaconSubjectInfo:ScenarioModel = ScenarioModel()
  
  // Data TO propagate
  var dataSendMethods: [DataSendMethod] = []
  var userEmail: String = ""
  
  // Environment
  var envType: EnvironmentType = EnvironmentType.unknown
  var envDetail:EnvironmentDetail = EnvironmentDetail.unknown
  fileprivate let environmentPickerView = ToolbarPickerView()
  var environmentPickerData: [[String]] = [[String]]()
  private var environments: [Environment] = []
  private var environmentSelected: Environment? = nil
  
  fileprivate let environmentTypePickerView = ToolbarPickerView()
  var environmentTypePickerData: [String] = []
  private var environmentTypes: [EnvironmentType] = []
  private var environmentTypesSelected: String = ""
  
  fileprivate let environmentDetailPickerView = ToolbarPickerView()
  var environmentDetailPickerData: [String] = []
  private var environmentDetails: [EnvironmentDetail] = []
  private var environmentDetailsSelected: String = ""
  
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
  
  // Activity
  fileprivate let subjectActivityPickerView = ToolbarPickerView()
  var subjectActivityPickerData: [String] = []
  private var subjectActivities: [Activity] = []
  private var subjectActivitySelected: String = ""
  
  // UI related
  @IBOutlet weak var environmentLabel: UILabel!
  @IBOutlet weak var environmentTextField: UITextField!
  @IBOutlet weak var onBodyLocationLabel: UILabel!
  @IBOutlet weak var onBodyLocationTextField: UITextField!
  @IBOutlet weak var subjectPoseLabel: UILabel!
  @IBOutlet weak var subjectPoseTextField: UITextField!
  @IBOutlet weak var subjectActivityLabel: UILabel!
  @IBOutlet weak var subjectActivityTextField: UITextField!
  
  // Data collection settings:
  @IBOutlet weak var mitllEmailButton: CheckBox!
  @IBOutlet weak var mitllServerButton: CheckBox!
  @IBOutlet weak var userEmailButton: CheckBox!
  @IBOutlet weak var userEmailTextField: UITextField!
  
  // Next
  @IBOutlet weak var nextButton: UIButton!
  
  
  // MARK: UIViewController overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //-------------------------
    // NOTE: MIT email and server decommissioned March 2021
    // Disable buttons. Text labels hidden from storyboard.
    mitllEmailButton.isHidden = true
    mitllServerButton.isHidden = true
    //-------------------------
    
    nextButton.setupRoundedButton()
    
    if scenarioSelected.type == .situational {
      if scenarioSelected.name.contains("selectPoseActivity") {
        showPoseAndActivity()
      } else {
        hidePoseAndActivity()
        subjectPoseLabel.text = "Subject pose: ANY"
        subjectActivityLabel.text = "Subject activity: ANY"
      }
      
      // HO and H1 do not take user environment or
      // on body location information, so should enable
      // the next button.
      nextButton.isEnabled = true
      
      // NOTE: For now H0 and H1 allow users to be in any
      // environment and any location - no data entry for
      // these things required.
      environmentTextField.isHidden =  true
      onBodyLocationTextField.isHidden = true
      environmentLabel.text = "Environment: ANY"
      onBodyLocationLabel.text = "On body location: ANY"
      
    } else if scenarioSelected.type == .structured {
      showPose()
      hideActivity()
      nextButton.isEnabled = false
      environmentTextField.isHidden =  false
      onBodyLocationTextField.isHidden = false
      environmentLabel.text = "Receiver Environment"
      onBodyLocationLabel.text = "Receiver On Body Location"
      subjectPoseLabel.text = "Receiver Pose"
      subjectActivityLabel.text = "Receiver Activity"
      initEnvironment()
      initOnBodyLocation()
      
    } else if scenarioSelected.type == .free_form {
      environmentLabel.text = "Receiver Environment"
      onBodyLocationLabel.text = "Receiver On Body Location"
      subjectPoseLabel.text = "Receiver Pose"
      subjectActivityLabel.text = "Receiver Activity"
      initEnvironment()
      initOnBodyLocation()
      showPoseAndActivity()
    }
    
    initDataCollectionUI()
    initMoveViewWithKeyboard()
  }
  
  func initEnvironmentUI() {
    
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
  
  func hidePose() {
    subjectPoseLabel.isHidden = true
    subjectPoseTextField.isHidden = true
  }
  
  func hideActivity() {
    subjectActivityLabel.isHidden = true
    subjectActivityTextField.isHidden = true
  }
  
  func hidePoseAndActivity() {
    hidePose()
    hideActivity()
  }
  
  func showPose() {
    initPose()
    subjectPoseLabel.isHidden = false
    subjectPoseTextField.isHidden = false
  }
  
  func showActivity() {
    initActivity()
    subjectActivityLabel.isHidden = false
    subjectActivityTextField.isHidden = false
  }
  
  func showPoseAndActivity() {
    initPoseAndActivity()
    showPose()
    showActivity()
  }
  
  func initPose() {
    // Subject Pose
    subjectPoseTextField.delegate = self
    subjectPosePickerData = SubjectPose.allCases.map { $0.rawValue }
    if typeSelected != TestType.situational {
      subjectPosePickerData = subjectPosePickerData.filter { $0 != "walking" }
    }
    createPickerView(textField: self.subjectPoseTextField,
                     toolbarPickerView: self.subjectPosePickerView)
  }
  
  func initActivity() {
    // Subject Activity
    subjectActivityTextField.delegate = self
    subjectActivityPickerData = Activity.allCases.map { $0.rawValue }
    createPickerView(textField: self.subjectActivityTextField,
                     toolbarPickerView: self.subjectActivityPickerView)
  }
  
  func initPoseAndActivity() {
    initPose()
    initActivity()
  }
  
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
  
  func initOnBodyLocation() {
    // On body location
    onBodyLocationTextField.delegate = self
    onBodyLocationPickerData = OnBodyLocation.allCases.map { $0.rawValue }
    createPickerView(textField: self.onBodyLocationTextField,
                     toolbarPickerView: self.onBodyLocationPickerView)
  }
  
  @IBAction func userEmailButton_TouchUpInside(_ sender: CheckBox) {
    userEmailTextField.isEnabled = userEmailButton.isChecked
  }
  
  
  // MARK: - Navigation
  
  // Send selected scenario name to CustomScenarioViewController
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch self.scenarioSelected.type {
    case .free_form:
      print("FREEFORM")
      let vc = segue.destination as? FreeFormTestViewController
      vc?.scenarioSelected = self.scenarioSelected
      vc?.metaData = self.metaData
      vc?.dataSendMethods = self.dataSendMethods
      vc?.userEmail = self.userEmail
      vc?.roleSelected = self.roleSelected
      vc?.partnerScenarioInfo = self.beaconSubjectInfo
      vc?.selfScenarioInfo = self.scenarioSelected
    case .situational:
      assert(false, "DEVELOPER - situational test handled by different path.")
    case .structured:
      print("STRUCTURED")
      let vc = segue.destination as? StructuredTestViewController
      vc?.scenarioSelected = self.scenarioSelected
      vc?.metaData = self.metaData
      vc?.dataSendMethods = self.dataSendMethods
      vc?.userEmail = self.userEmail
      vc?.roleSelected = self.roleSelected
      vc?.beaconSubjectInfo = self.beaconSubjectInfo
    case .none:
      print("Invalid test type")
    }
    
  }
  
  func updateScenarioSelected() {
    var env = Environment()
    if let envValueCsv = environmentTextField.text {
      let envArr = envValueCsv.components(separatedBy: ", ")
      if envArr.count == 2 {
        env.envType = EnvironmentType(rawValue: envArr[0])!
        env.envDetail = EnvironmentDetail(rawValue: envArr[1])!
      }
    }
    
    self.scenarioSelected.environmentType = env.envType
    self.scenarioSelected.environmentDetail = env.envDetail
    
    var bodyLoc = "none"
    if let bodyValue = onBodyLocationTextField.text {
      bodyLoc = bodyValue
    }
    if let bodyLocActual = OnBodyLocation(rawValue: bodyLoc) {
      self.scenarioSelected.onBodyLocation = bodyLocActual
    }
    
    var pose = ""
    if let poseValue = subjectPoseTextField.text {
      pose = poseValue
    }
    if let poseActual = SubjectPose(rawValue: pose) {
      self.scenarioSelected.subjectPose = poseActual
    }
    
    var activity = ""
    if let activityValue = subjectActivityTextField.text {
      activity = activityValue
    }
    if let activityActual = Activity(rawValue: activity) {
      self.scenarioSelected.subjectActivity = activityActual
    }
  }
  
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
  
  
  // MARK: Actions
  
  // Check boxes
  
  func isRequiredAndValidSendMethod() -> Bool {
    let atLeastOneSendMethodChecked = (mitllEmailButton.isChecked || userEmailButton.isChecked || mitllServerButton.isChecked)
    if userEmailButton.isChecked {
      // is the text entry valid?
      var em = userEmailTextField.text ?? ""
      em =  userEmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      if em.isValidEmail() {
        return true
      } else {
        return false
      }
    }
    return atLeastOneSendMethodChecked
  }
  
  
  @objc func onCheckBoxValueChange(_ sender: CheckBox) {
    if sender == userEmailButton {
      userEmailTextField.isEnabled = userEmailButton.isChecked
    }
    if (allRequiredTextFieldsAreFilled() && isRequiredAndValidSendMethod()) {
      nextButton.isEnabled = true
    } else {
      nextButton.isEnabled = false
    }
  }
  
  @IBAction func nextButton_TouchUpInside(_ sender: UIButton) {
    updateScenarioSelected()
    updateDataSendMethods()
    userEmail = userEmailTextField.text ?? ""
    switch self.scenarioSelected.type {
    case .free_form:
      self.performSegue(withIdentifier: "FreeFormTestViewController", sender: self)
    case .situational:
      self.performSegue(withIdentifier: "FreeFormTestViewController", sender: self)
    case .structured:
      self.performSegue(withIdentifier: "StructuredTestViewController", sender: self)
    case .none:
      print("Invalid test type")
    }
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
    } else if pickerView == subjectActivityPickerView {
      title.text =  subjectActivityPickerData[row]
    }
    
    title.textAlignment = .center
    
    return title
  }
  
  // Number of columns of data
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    if pickerView == environmentPickerView {
      return 2
    } else {
      return 1
    }
  }
  
  // Number of rows of data
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    var count = 0
    if pickerView == environmentPickerView {
      count = environmentPickerData[component].count
    } else if pickerView == onBodyLocationPickerView {
      count = onBodyLocationPickerData.count
    } else if pickerView == subjectPosePickerView {
      count = subjectPosePickerData.count
    } else if pickerView == subjectActivityPickerView {
      count = subjectActivityPickerData.count
    }
    
    return count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    
    var msg = ""
    if pickerView == environmentPickerView {
      msg = environmentPickerData[component][row]
    } else if pickerView == onBodyLocationPickerView {
      msg = onBodyLocationPickerData[row]
    } else if pickerView == subjectPosePickerView {
      msg = subjectPosePickerData[row]
    } else if pickerView == subjectActivityPickerView {
      msg = subjectActivityPickerData[row]
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
    } else if pickerView == subjectActivityPickerView {
      subjectActivitySelected = subjectActivityPickerData[row]
      subjectActivityTextField.text = subjectActivitySelected
    }
        
    if (allRequiredTextFieldsAreFilled() && isRequiredAndValidSendMethod()) {
      nextButton.isEnabled = true
    } else {
      nextButton.isEnabled = false
    }
  }
  
  
  // MARK: Methods
    
  func createPickerView(textField: UITextField, toolbarPickerView: ToolbarPickerView) {
    textField.inputView = toolbarPickerView
    textField.inputAccessoryView = toolbarPickerView.toolbar
    
    toolbarPickerView.dataSource = self
    toolbarPickerView.delegate = self
    toolbarPickerView.toolbarDelegate = self
    
    toolbarPickerView.selectedRow(inComponent: 0)
    toolbarPickerView.reloadAllComponents()
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
      // userEmailTextField.backgroundColor = .white
      nextButton.isEnabled = false
    }
    return true
  }
  
  func allRequiredTextFieldsAreFilled() -> Bool {
    let isCommonItemsOK = (environmentSelected?.envType.rawValue != "") &&
      (environmentSelected?.envDetail.rawValue != "") &&
      (environmentTextField.text != "") &&
      (onBodyLocationTextField.text != "") &&
      (subjectPoseTextField.text != "")
    if typeSelected == TestType.structured {
      if (isCommonItemsOK) {
        return true
      }
    } else if typeSelected == TestType.free_form {
      if isCommonItemsOK && (subjectActivityTextField.text != "") {
        return true
      }
    }
    return false
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == userEmailTextField {
      // strip any spaces caused by auto-complete
      var em = userEmailTextField.text ?? ""
      let cleanedText = userEmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
      em = cleanedText
      if em.isValidEmail() {
        print("[textFieldDidEndEditing] email OK")
        self.userEmail = em
        userEmailTextField.layer.borderWidth = 1
        userEmailTextField.layer.borderColor = UIColor.gray.cgColor
        userEmailTextField.layer.cornerRadius = 5
        
        self.nextButton.isEnabled = allRequiredTextFieldsAreFilled() ? true : false
      } else {
        print("[textFieldDidEndEditing] Invalid email")
        userEmailTextField.text = ""
        userEmailTextField.layer.borderWidth = 2
        userEmailTextField.layer.borderColor = UIColor.red.cgColor
        userEmailTextField.layer.cornerRadius = 5
        self.nextButton.isEnabled = false
      }
    }
    
    if (allRequiredTextFieldsAreFilled() && isRequiredAndValidSendMethod()) {
      nextButton.isEnabled = true
    } else {
      nextButton.isEnabled = false
    }
  }
}


extension TestRunDetailSetupViewController: ToolbarPickerViewDelegate {
  func didTapDone(_ sender: UIPickerView) {
    var row = 0
    switch sender {
    case environmentPickerView:
      row = self.environmentPickerView.selectedRow(inComponent: 0)
      self.environmentPickerView.selectRow(row, inComponent: 0, animated: false)
      self.environmentTextField.resignFirstResponder()
      
    case onBodyLocationPickerView:
      row = self.onBodyLocationPickerView.selectedRow(inComponent: 0)
      self.onBodyLocationPickerView.selectRow(row, inComponent: 0, animated: false)
      self.onBodyLocationTextField.resignFirstResponder()
      
    case subjectPosePickerView:
      row = self.subjectPosePickerView.selectedRow(inComponent: 0)
      self.subjectPosePickerView.selectRow(row, inComponent: 0, animated: false)
      self.subjectPoseTextField.resignFirstResponder()
      
    case subjectActivityPickerView:
      row = self.subjectActivityPickerView.selectedRow(inComponent: 0)
      self.subjectActivityPickerView.selectRow(row, inComponent: 0, animated: false)
      self.subjectActivityTextField.resignFirstResponder()
      
    default:
      print("Invalid picker view")
    }
  }
  
  func didTapCancel(_ sender: UIPickerView) {
    if sender == onBodyLocationPickerView {
      self.onBodyLocationTextField.text = nil
      self.onBodyLocationTextField.resignFirstResponder()
    } else {
      self.environmentTextField.text = nil
      self.environmentTextField.resignFirstResponder()
      
      self.subjectPoseTextField.text = nil
      self.subjectPoseTextField.resignFirstResponder()
      
      self.subjectActivityTextField.text = nil
      self.subjectActivityTextField.resignFirstResponder()
    }
  }
  
}
