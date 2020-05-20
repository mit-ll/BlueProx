//
//  FreeFormTestViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import MessageUI


class FreeFormTestViewController: UIViewController, RunCompleteDelegate, RSSIDelegate, MFMailComposeViewControllerDelegate, UIActivityItemSource {
  
  
  // MARK: Properties
  
  // Consts - email address
  let defaultEmail: String = "bluetooth-proximity-data@mit.edu"
  
  // Propagated
  var typeSelected: TestType = TestType.free_form
  var metaData: MetaData = MetaData()
  var scenarioSelected: ScenarioModel = ScenarioModel()
  var dataSendMethods: [DataSendMethod] = []
  var userEmail: String = ""
  var roleSelected: String = ""
  var partnerScenarioInfo: ScenarioModel = ScenarioModel()
  var selfScenarioInfo: ScenarioModel = ScenarioModel()
  
  // Workflow related
  var sessionID: String = ""
  var currentState: StructuredTestStates = .idle
  var activateSensors: ActivateSensors? = nil
  var range: Int = 0
  var angle: Int = 0
  var loopList: [(partnerLoc: Int, selfLoc: Int, subjAngle: Int)] = []
  var loopStartTime: String = ""
  
  // Data collection
  // Note, in this VC, only one element is used
  var allLoopData: [SessionData] = []
  var clientServerFormatter: ClientServerFormatter? = nil
  
  
  // UI
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var rangeHeaderLabel: UILabel!
  @IBOutlet weak var rangeStepper: UIStepper!
  @IBOutlet weak var rangeLabel: UILabel!
  @IBOutlet weak var angleHeaderLabel: UILabel!
  @IBOutlet weak var angleStepper: UIStepper!
  @IBOutlet weak var angleLabel: UILabel!
  @IBOutlet weak var situationalRangeLabel: UILabel!
  @IBOutlet weak var situationalDesciptionTextView: UITextView!
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var sendDataButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  @IBOutlet weak var statusButton: UIButton!
  @IBOutlet weak var proxRSSILabel: UILabel!
  @IBOutlet weak var otherRSSILabel: UILabel!
  
  
  // MARK: Enums
  
  enum StructuredTestStates: Int {
    case idle
    case loopStarted
  }
  
  let child = SpinnerViewController()
  
  
  // MARK: UIView overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    currentState = .idle
    
    // Instantiate activateSensors (required), and
    // set a reference to the delegating object
    var nextDurationSec = scenarioSelected.testDurationMinutes * 60
    
    #if targetEnvironment(simulator)
    nextDurationSec = 3
    #endif
    
    #if DEBUG
    nextDurationSec = 10
    #endif
    
    // In free form / situational (both of which use this VC),
    // there is only one item in loop list:
    loopList.removeAll()
    if typeSelected == TestType.situational {
      loopList.insert((partnerLoc: scenarioSelected.partnerLocations![0], selfLoc: scenarioSelected.selfLocations![0], subjAngle: -999), at: 0)
    }
    
    let sensorsEnabledSettings = EngineeringSettings(enabledGroup: SensorsEnabledGroup.noProx)
    activateSensors = ActivateSensors(role: nil, nextTimerDurationSeconds: nextDurationSec, sensorsEnabledSettings: sensorsEnabledSettings)
    activateSensors!.runCompleteDelegate = self
    activateSensors!.rssiDelegate = self
    
    initUI()
    
    UIDevice.current.isProximityMonitoringEnabled = false
    
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      self,
      selector: #selector(proximityChanged),
      name: UIDevice.proximityStateDidChangeNotification,
      object: nil)
  }
  
  
  // MARK: Notification Handlers
  
  // Keep proximity sensor off as it messes with bluetooth
  // and other sensors
  @objc func proximityChanged() {
    print("[FFVC | proximityChanged] UIDevice.current.isProximityMonitoringEnabled: " + UIDevice.current.isProximityMonitoringEnabled.description)
    UIDevice.current.isProximityMonitoringEnabled = false
  }
  
  
  // MARK: Conform to RSSIDelegate
  
  func updateRSSIValues(proxRSSI: Int, otherRSSI: Int) {
    proxRSSILabel.text = proxRSSI.description
    otherRSSILabel.text = otherRSSI.description
  }
  
  
  // MARK: Conform to RunCompleteDelegate
  
  // Delegate method of activateSensor
  func didRunToCompletion() {
    print("[FFTVC | didRunToCompletion] thread: \(Thread.current)")
    
    Utility.chooChooAndVibrate()
    updateScene()
    
    print("[FFVC | didRunToCompletion] UIDevice.current.isProximityMonitoringEnabled: \( UIDevice.current.isProximityMonitoringEnabled.description)")
    
    let endTime = Utility.getTimestamp()
    
    if typeSelected == TestType.free_form {
      loopList.insert((partnerLoc: range, selfLoc: range, subjAngle: angle), at: 0)
    }
    
    if clientServerFormatter == nil {
      clientServerFormatter = ClientServerFormatter(
        metaData: metaData,
        partnerScenario: partnerScenarioInfo,
        selfScenario: selfScenarioInfo,
        loopList: loopList,
        loopStartTime: loopStartTime)
    }
    
    print("typeSelected: \(typeSelected.rawValue)")
    if let loopData = clientServerFormatter?.generateSessionData(
      sessionID: sessionID,
      loopNum: 0,
      endTime: endTime,
      activateSensors: activateSensors!,
      testType: typeSelected) {
      allLoopData.append(loopData)
    } else {
      assert(false, "DEVELOPER - loopData not populated")
    }
    
    self.startStopButton.isEnabled = false
    setEnabledSendDataButton()
    
    self.thankYouAlert()
  }
  
  func didNotFindBeacon() {
    // Scanner started, did not find BlueProxTx beacon
    // within specified time (3 s)
    print("[FFVC | didNotFindBeacon] currentState: \(currentState.rawValue.description)")
    resetLog()
    abortAlert(title: "ABORTED", message: "No partner found. Please try again.")
  }
  
  // MARK: Methods
  
  func initUI(){
    resetButton.isHidden = true
    
    headerLabel.text = scenarioSelected.type.rawValue + ": " + scenarioSelected.name
    
    startStopButton.setupRoundedButton()
    sendDataButton.setupRoundedButton()
    resetButton.setupRoundedButton()
    statusButton.setupRoundedButton(backgroundColor: .red)
    
    statusButton.blink(enabled: false)
    
    self.startStopButton.setTitle("Start", for: .normal)
    startStopButton.isEnabled = true
    sendDataButton.isEnabled = false
    
    self.rangeStepper.isEnabled = true
    self.angleStepper.stepValue = 45.0
    self.angleStepper.maximumValue = 360.0
    self.angleStepper.minimumValue = 0.0
    self.angleStepper.wraps = true
    
    self.angleStepper.isEnabled = true
    
    self.resetButton.isEnabled = true
    
    if self.scenarioSelected.type == TestType.situational {
      angleHeaderLabel.isHidden = true
      angleStepper.isHidden = true
      angleLabel.isHidden = true
      angle = -999
      
      rangeHeaderLabel.isHidden = true
      situationalRangeLabel.isHidden = true
      rangeStepper.isHidden = true
      rangeLabel.isHidden = true
      range = self.scenarioSelected.selfLocations![0]
      
      situationalDesciptionTextView.setupRoundedTextView()
      situationalDesciptionTextView.isHidden = false
      situationalDesciptionTextView.text = scenarioSelected.summary ?? ""
      
      if self.scenarioSelected.name.contains("H0") {
        situationalRangeLabel.text = ">= 10"
      } else if self.scenarioSelected.name.contains("H1") {
        situationalRangeLabel.text = "<= 6"
      }
    } else if self.scenarioSelected.type == TestType.free_form {
      rangeHeaderLabel.isHidden = false
      situationalRangeLabel.isHidden = true
      angleHeaderLabel.isHidden = false
      angleStepper.isHidden = false
      angleLabel.isHidden = false
      angle = 0
      
      situationalDesciptionTextView.isHidden = true
    }
  }
  
  func setEnabledSendDataButton() {
    if self.dataSendMethods.count > 0 {
      sendDataButton.isEnabled = true
    } else {
      sendDataButton.isEnabled = false
    }
  }
  
  func resetAutoDone() {
    reset()
    startStopButton.isEnabled = false
    startStopButton.setTitle("Done", for: .normal)
    
    setEnabledSendDataButton()
    sendDataButton.backgroundColor = .orange
  }
  
  func createSpinnerView() {
    // add the spinner view controller
    addChild(child)
    child.view.frame = view.frame
    view.addSubview(child.view)
    child.didMove(toParent: self)
  }
  
  func removeSpinnerView() {
    DispatchQueue.main.async() {
      // then remove the spinner view controller
      self.child.willMove(toParent: nil)
      self.child.view.removeFromSuperview()
      self.child.removeFromParent()
    }
  }
  
  func updateScene(_ sender: UIButton? = nil, _ dataSentOK: Bool? = false) {
    print("[FFTVC | updateScene] thread: \(Thread.current)")
    switch currentState {
    case .idle:
      print("idle")
      
      resetLog()
      
      if sessionID == "" {
        sessionID = UUID().description
      }
      loopStartTime = Utility.getTimestamp()
      currentState = .loopStarted
      
      DispatchQueue.main.async {
        self.startStopButton.setTitle("Abort", for: .normal)
        self.startStopButton.isEnabled = true
        self.sendDataButton.isEnabled = false
        self.sendDataButton.setupRoundedButton()
        self.resetButton.isEnabled = true
        self.rangeStepper.isEnabled = false
        self.angleStepper.isEnabled = false
        
        self.statusButton.backgroundColor = UIColor.green
        self.statusButton.blink(enabled: true)
      }
      
      activateSensors!.startRun(
        range: range,
        angle: angle,
        metaData: metaData,
        scenarioData: selfScenarioInfo,
        beaconSubjectInfo: partnerScenarioInfo)
      
      UIDevice.current.isProximityMonitoringEnabled = false
      
    case .loopStarted:
      print("loopStarted")
      
      // If Start/Abort button was pressed, warn,
      // else must have received end of test signal
      // from activateSensors object
      if sender != nil {
        currentState = .idle
        
        print("Test aborted, start over")
        self.activateSensors!.stopRun()
        
        self.statusButton.backgroundColor = UIColor.red
        self.statusButton.blink(enabled: false)
        abortAlert()
        
      } else {
        currentState = .idle
        
        activateSensors!.stopRun()
        
        self.startStopButton.setTitle("Start", for: .normal)
        self.startStopButton.isEnabled = false
        self.sendDataButton.isEnabled = true
        
        self.statusButton.backgroundColor = UIColor.red
        self.statusButton.blink(enabled: false)
        
        self.rangeStepper.isEnabled = true
        self.angleStepper.isEnabled = true
        self.resetButton.isEnabled = true
        
      }
    }
  }
  
  func reset() {
    currentState = .idle
    resetData()
    initUI()
  }
  
  func resetData() {
    proxRSSILabel.text = 0.description
    otherRSSILabel.text = 0.description
  }
  
  
  // MARK: Actions
  
  // Set up subject with UIActivityViewController
  func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    return "PACT data - from BlueProximity iOS app"
  }
  
  func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
    return "PACT data - from BlueProximity iOS app"
  }
  
  func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
    if activityType == .mail {
      return "Data contained in attachment. Please send to: bluetooth-proximity-data@mit.edu"
    } else {
      
      activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
        // NOTE: if avc is cancelled, it reaches here but completed is
        // false. If avc completes activity, it reaches here and completed
        // is true. There is no way to know if the avc is dismissed via cancel.
        // if completed {
        self.startStopButton.isEnabled = true
        if self.dataSendMethods.contains(.mitllServer) {
          self.postData()
        } else {
          // Delete old logs, start new one
          self.resetLog()
          
          self.startStopButton.setTitle("Start", for: .normal)
          self.startStopButton.isEnabled = true
          
          self.sendDataButton.setupRoundedButton()
          self.sendDataButton.isEnabled = false
        }
        // }
      }
      
      return "Data contained in attachment. Please send to: bluetooth-proximity-data@mit.edu"
    }
  }
  
  func sendEmailBackup(emailAddresses: [String]) {
    print(">>> UIActivityViewController <<< Mailing to : " + emailAddresses.description)
    
    if let logger = activateSensors!.logger {
      let path = logger.fileURL.path
      let fileURL = URL(fileURLWithPath: path)
      print("fileURL: \(fileURL)")
      
      let activityVC = UIActivityViewController(activityItems: [self, fileURL], applicationActivities: nil)
      present(activityVC, animated: true, completion: nil)
    }
  }
  
  func sendEmail(emailAddresses: [String]) {
    print("Mailing to : " + emailAddresses.description)
    
    // Get data to send
    if let logger = activateSensors!.logger {
      let path = logger.fileURL.path
      let fileURL = URL(fileURLWithPath: path)
      print("fileURL: \(fileURL)")
      
      // Get contents of file:
      // NOTE: Can get contents of file and send as
      // body message. However, here are sending as
      // an attachment. Use the let contents line
      // if change to putting in body.
      // let contents = Utility.getFileContents(path: path)
      let bodyMessage = "Data contained in attachment"
      
      // Get file as Data to send as attachment
      let fileData = Utility.getFileData(path: path)
      
      if MFMailComposeViewController.canSendMail() {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self;
        mail.setToRecipients(emailAddresses)
        mail.setSubject("PACT data - from BlueProximity iOS app")
        mail.setMessageBody(bodyMessage, isHTML: false)
        
        // Send as attachement:
        if let fdata = fileData {
          mail.addAttachmentData(fdata as Data, mimeType: "text/txt", fileName: logger.fileName)
        }
        self.present(mail, animated: true, completion: nil)
      } else {
        print("Mail services not enabled ... are you running from the simulator? Can only e-mail from actual device.")
        
        sendEmailBackup(emailAddresses: emailAddresses)
        
      }
    }
  }
  
  func mailServicesAlert() {
    print("Mail services not enabled ... are you running from the simulator? Can only e-mail from actual device.")
    DispatchQueue.main.async {
      let alert = UIAlertController(title: "FAILURE", message: "Mail services not enabled.", preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        print("Continue - mail services not enabled.")
        UIDevice.current.isProximityMonitoringEnabled = false
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    if let _ = error {
      self.dismiss(animated: true, completion: nil)
    }
    switch result {
    case .cancelled:
      print("Cancelled")
      break
    case .sent:
      print("Mail sent successfully")
      self.startStopButton.setTitle("Start", for: .normal)
      self.startStopButton.isEnabled = true
      self.sendDataButton.setupRoundedButton()
      self.sendDataButton.isEnabled = false
      break
    case .failed:
      print("Sending mail failed")
      break
    default:
      break
    }
    
    controller.dismiss(animated: true, completion: mailComposeCompletion)
  }
  
  func resetLog() {
    activateSensors!.deleteLogs()
    activateSensors!.createNewLog()
    resetLoopData()
  }
  
  func resetLoopData() {
    allLoopData = []
    clientServerFormatter = nil
  }
  
  func mailComposeCompletion() {
    // Delete old logs, start new one
    if dataSendMethods.contains(.mitllServer) {
      postData()
    } else {
      // Delete old logs, start new one
      resetLog()
    }
  }
  
  @IBAction func startStopButton_TouchUpInside(_ sender: UIButton) {
    print("[FFTVC | startStopButton_TouchUpInside] thread: \(Thread.current)")
    // updateScene(sender)
    if startStopButton.title(for: .normal) == "Reset" {
      print("[startStopButton_TouchUpInside] Reset, currentState: " + currentState.rawValue.description)
      startStopButton.setTitle("Start", for: .normal)
      startStopButton.isEnabled = true
      reset()
    } else if startStopButton.title(for: .normal) == "Done" {
      resetLog()
      updateScene(sender)
    } else {
      updateScene(sender)
    }
  }
  
  @IBAction func sendDataButton_TouchUpInside(_ sender: UIButton) {
    var emailAddresses: [String] = []
    
    // Get list of emails
    // If any emails, send email first.
    // When email completes, send via server
    for sendMethod in dataSendMethods {
      switch sendMethod {
      case .mitllEmail:
        emailAddresses.append(defaultEmail)
      case .mitllServer:
        break
      case .userEmail:
        emailAddresses.append(self.userEmail)
      }
    }
    
    if emailAddresses.count > 0 {
      sendEmail(emailAddresses: emailAddresses)
    } else if dataSendMethods.contains(.mitllServer) {
      self.postData()
    }
  }
  
  @IBAction func reset_TouchUpInside(_ sender: UIButton) {
    self.activateSensors!.stopRun()
    range = 0
    angle = 0
    self.rangeStepper.value = Double(range)
    self.angleStepper.value = Double(angle)
    self.rangeLabel.text = range.description
    self.angleLabel.text = angle.description
    
    self.startStopButton.setTitle("Start", for: .normal)
    self.startStopButton.isEnabled = true
    self.sendDataButton.isEnabled = false
    self.rangeStepper.isEnabled = true
    self.angleStepper.isEnabled = true
    self.angleStepper.stepValue = 45.0
    self.angleStepper.maximumValue = 360.0
    self.angleStepper.minimumValue = 0.0
    self.angleStepper.wraps = true
    
    self.proxRSSILabel.text = "0"
    self.otherRSSILabel.text = "0"
  }
  
  func oneActionAlert(alertTitle: String, alertMessage: String, actionTitle: String = "Continue",handler: ((UIAlertAction) -> Void)? = nil) {
    DispatchQueue.main.async {
      self.statusButton.backgroundColor = UIColor.red
      self.statusButton.blink(enabled: false)
      // Abort alert
      let alert = UIAlertController(title: "WARNING", message: "No email addresses selected. Please click Back and enter email choices", preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func abortAlert(title: String = "ABORTED", message: String = "Restart test") {
    DispatchQueue.main.async {
      self.statusButton.backgroundColor = UIColor.red
      self.statusButton.blink(enabled: false)
      let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        self.reset()
        UIDevice.current.isProximityMonitoringEnabled = false
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func thankYouAlert() {
    DispatchQueue.main.async {
      var thankYouMsg = "Scenario complete. You can repeat this scenario, or go back and choose a different test scenario."
      if self.dataSendMethods.count > 0 {
        thankYouMsg = thankYouMsg + "\n\nPlease click Send Data."
      }
      self.statusButton.backgroundColor = UIColor.red
      self.statusButton.blink(enabled: false)
      let alert = UIAlertController(title: "THANK YOU!", message: thankYouMsg, preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        self.resetAutoDone()
        UIDevice.current.isProximityMonitoringEnabled = false
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func postDataSuccessHandler(json: [String:AnyObject]) {
    print("[TLVC | postDataSuccessHandler]")
    resetLog()
    
    self.startStopButton.setTitle("Start", for: .normal)
    self.startStopButton.isEnabled = true
    
    self.sendDataButton.setupRoundedButton()
    self.sendDataButton.isEnabled = false
  }
  
  func postDataFailureHandler(errMsg: String?) {  // error: [Error]?) {
    print("[TLVC | postDataFailureHandler]")
    // Alert
    let alert = UIAlertController(title: "ERROR", message: "Data failed to send. Please check that you are connected to the internet.", preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: "Resend", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
      self.postData()
    }))
    alert.addAction(UIAlertAction(title: "Try Again Later", style: .cancel, handler: { (action: UIAlertAction!) in
      self.resetLog()
      self.startStopButton.isEnabled = false
      self.sendDataButton.isEnabled = false
      
    }))
    present(alert, animated: true, completion: nil)
  }
  
  func postData() {
    let urlString = "https://c19blue.hadr.ll.mit.edu/mitll/api/v1/data"
    
    // var allDataGenerated: AllData?
    var jsonDict: [String : Any]?
    var jsonAny: Any?
    if let csf = clientServerFormatter {
      let allDataGenerated = csf.generateAllData(allLoopData: allLoopData)
      if let adt = allDataGenerated {
        (jsonDict, jsonAny) = csf.generateJsonDataDict(allData: adt)
      }
    }
    
    guard let dataDict = jsonDict else {
      postDataFailureHandler(errMsg: "")
      return
    }
    guard let json = jsonAny else {
      postDataFailureHandler(errMsg: "")
      return
    }
    
    let parameters: [String: Any] = dataDict
    // TODO: Not needed (yet?): let headers =
    createSpinnerView()
    
    AF.request(URL.init(string: urlString)!,
               method: .post,
               parameters: parameters,
               encoding: JSONEncoding.default,
               headers: nil
    ).responseJSON { (response) in
      // headers: headers).responseJSON { (response) in
      self.removeSpinnerView()
      if let statusCode = response.response?.statusCode {
        print("[postData] response.statusCode: " + statusCode.description)
      } else {
        print("[postData] response.statusCode: was nil")
      }
      switch response.result {
      case .success(_):
        var isSuccess = false
        let responseStatusCode: Int = response.response!.statusCode
        if 200...299 ~= responseStatusCode {
          print("statusCode \(responseStatusCode): is in range 200 - 299, OK")
          isSuccess = true
        } else {
          print("statusCode \(responseStatusCode): - BAD")
        }
        if isSuccess {
          self.postDataSuccessHandler(json: (json as! [String:AnyObject]))
        } else {
          self.postDataFailureHandler(errMsg: nil)
        }
        break
      case .failure(let error):
        self.postDataFailureHandler(errMsg: error.localizedDescription)
        break
      }
    }
  }
  
  
  //   MARK: Actions
  
  @IBAction func rangeStepper_ValueChanged(_ sender: Any) {
    range = Int(rangeStepper.value)
    rangeLabel.text = range.description
  }
  
  @IBAction func setAngle_ValueChanged(_ sender: Any) {
    angle = Int(angleStepper.value)
    angleLabel.text = angle.description
    startStopButton.isEnabled = true
    self.angleStepper.stepValue = 45.0
    self.angleStepper.maximumValue = 360.0
    self.angleStepper.minimumValue = 0.0
    self.angleStepper.wraps = true
  }
  
}
