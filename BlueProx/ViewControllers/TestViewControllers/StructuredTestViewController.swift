//
//  StructuredTestViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit
import Alamofire
import AVFoundation
import MessageUI


class StructuredTestViewController: UIViewController, RunCompleteDelegate, MFMailComposeViewControllerDelegate, UIActivityItemSource {
  
  // MARK: Enums
  
  enum StructuredTestStates: Int {
    case idle
    case loopStarted
    case loopAborted
    case loopEnded
  }
  
  
  // MARK: Properties
  
  // Consts - email address
  let defaultEmail: String = "bluetooth-proximity-data@mit.edu"

  // Propagated
  var metaData: MetaData = MetaData()
  var scenarioSelected: ScenarioModel = ScenarioModel()
  var dataSendMethods: [DataSendMethod] = []
  var userEmail: String = ""
  var roleSelected: String = ""
  // NOTE: Reusing original data structures for JSON Schema refactor
  var beaconSubjectInfo:ScenarioModel = ScenarioModel()


  // Workflow related
  var sessionID: String = ""
  let autoMoveThroughAngles = false
  var isStationComplete = false
  var currentState: StructuredTestStates = .idle
  var totalNumLoops: Int = 0
  var currentLoop: Int = 0
  var loopList: [(partnerLoc: Int, selfLoc: Int, subjAngle: Int)] = []
  var loopStartTime: String = ""
  var activateSensors: ActivateSensors?
  
  // Data collection
  var allLoopData: [SessionData] = []
  var clientServerFormatter: ClientServerFormatter? = nil
  
  // UI related
  @IBOutlet weak var runDescriptionLabel: UILabel!
  @IBOutlet weak var stationNumberLabel: UILabel!
  @IBOutlet weak var startStopButton: UIButton!
  @IBOutlet weak var sendDataButton: UIButton!
  @IBOutlet weak var receiverPositionValueLabel: UILabel!
  @IBOutlet weak var subjectAngleValueLabel: UILabel!
  @IBOutlet weak var statusButton: UIButton!
  
  let child = SpinnerViewController()
  
  
  // MARK: UIView overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    currentState = .idle
    
    // Instantiate activateSensors (required), and
    // set a reference to the delegating object
    
    
    let beaconIsBlueProx = metaData.partnerTester.model == ApplePhone.notBlueProxTx.rawValue ? false : true
    activateSensors = ActivateSensors(role: roleSelected, nextTimerDurationSeconds: scenarioSelected.loopDurationSeconds, beaconIsBlueProx: beaconIsBlueProx)
    activateSensors!.runCompleteDelegate = self
        
    initUI()
    
    if self.dataSendMethods.count == 0 {
      self.sendDataButton.isEnabled = false
      displayNoSendDataMethodsAlert()
    }
    
    initScenario()

    UIDevice.current.isProximityMonitoringEnabled = false
      
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(
      self,
      selector: #selector(proximityChanged),
      name: UIDevice.proximityStateDidChangeNotification,
      object: nil)
  }
  
  // Keep proximity sensor off as it messes with bluetooth
  // and other sensors
  @objc func proximityChanged() {
    print("[STVC | proximityChanged] UIDevice.current.isProximityMonitoringEnabled: " + UIDevice.current.isProximityMonitoringEnabled.description)
    UIDevice.current.isProximityMonitoringEnabled = false
  }

  
  // MARK: Conform to RunCompleteDelegate
  
  func didNotFindBeacon() {
    // Scanner started, did not find BlueProxTx beacon
    // within specified time (3 s)
    currentState = .loopAborted
    resetLog()
    abortAlert(title: "ABORTED", message: "No beacon found. Please try again.")
  }
  
  // Only get here when run completes specified
  // time to run
  func didRunToCompletion() {
    if currentState != .loopAborted {
      updateScene()
      
      let (isRangeDone, isTestDone) = self.getNext()
      self.updateNextPositionUI(isRangeDone: isRangeDone, isDone: isTestDone)
      
      let endTime = Utility.getTimestamp()
      
      // Current loop gets updated ready for next loop, so adjust
      // for previous value. If at end, will roll over to 0 giving
      // -1 here. Reassign to last loop number.
      var loopNum = currentLoop - 1
      if loopNum < 0 {
        loopNum = loopList.count - 1  // zero indexed
      }

      if clientServerFormatter == nil {
        clientServerFormatter = ClientServerFormatter(
          metaData: metaData,
          partnerScenario: beaconSubjectInfo,
          selfScenario: scenarioSelected,
          loopList: loopList,
          loopStartTime: loopStartTime)
      }
      
      if let loopData = clientServerFormatter?.generateSessionData(
        sessionID: sessionID,
        loopNum: loopNum,
        endTime: endTime,
        activateSensors: activateSensors!,
        testType: TestType.structured) {
        allLoopData.append(loopData)
      } else {
        assert(false, "DEVELOPER - loopData not populated")
      }

      if !isRangeDone && !isTestDone {
        
        Utility.tweetAndVibrate()

        currentState = .idle
        sendDataButton.isEnabled = false
        
        UIDevice.current.isProximityMonitoringEnabled = false

        self.statusButton.backgroundColor = UIColor.red
        self.statusButton.blink(enabled: false)
        
        UIDevice.current.isProximityMonitoringEnabled = false

        // If more loops, wait 8 s for person to get
        // into position, and then proceed.
        let delayInSeconds = 8.0
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { [weak self] in
          guard let self = self else {
            return
          }
          self.currentState = .idle
          // Progammatically click startStopButton
          self.startStopButton_TouchUpInside(UIButton())
        }
      }
      // If isRangeDone and not end of test, sound range done signal
      else if isRangeDone && !isTestDone {
        Utility.audioToneAndVibrate()
        
        currentState = .idle
        self.startStopButton.isEnabled = false
        setEnabledSendDataButton()
        
        Utility.audioToneAndVibrate()

        if self.dataSendMethods.count != 0 {
          nextStationAlert()
        }
      }
      else if isTestDone {
        print("\nxxxxxxx - TEST IS COMPLETE - xxxxxxxx\n")
        
        isStationComplete = true
        
        Utility.chooChooAndVibrate()

        self.startStopButton.isEnabled = false
        setEnabledSendDataButton()

        self.thankYouAlert()
      }
    }
    
    UIDevice.current.isProximityMonitoringEnabled = false
  }
  
  
  // MARK: Methods
  
  func initUI(){
    if self.roleSelected == "Beacon" {
      // runScenarioLabel.text = "Run Scenario - Beacon"
      runDescriptionLabel.text = "Click Start at the same time as the receiver tester. Stay in position. You can monitor the receiver's position as indicated below."
    } else if self.roleSelected == "Receiver" {
      // runScenarioLabel.text = "Run Scenario - Receiver"
      var msg = "\u{2022} Move into position shown\n"
      msg = msg + "\u{2022} (NOTE: 0 deg angle faces the beacon)\n"
      msg = msg + "\u{2022} Press Start\n"
      msg = msg + "\u{2022} At each 'tweet', rotate clockwise to angle shown\n"
      msg = msg + "\u{2022} At 'audio tone', take phone, press Send Data\n"
      msg = msg + "\u{2022} Move to next position\n"
      msg = msg + "\u{2022} Press Start, repeat\n"
      msg = msg + "\u{2022} Repeat angles and positions\n"
      msg = msg + "\u{2022} At 'train' sound, test complete"
      
      runDescriptionLabel.text = msg
    }
    runDescriptionLabel.setupRoundedLabel()
    startStopButton.setupRoundedButton()
    sendDataButton.setupRoundedButton()
    statusButton.setupRoundedButton(backgroundColor: .red)
    statusButton.blink(enabled: false)
    
    self.startStopButton.setTitle("Start", for: .normal)
    updateLoopCountLabel()
    
    startStopButton.isEnabled = true
    sendDataButton.isEnabled = false
  }
  
  func setEnabledSendDataButton() {
    if self.dataSendMethods.count > 0 {
        sendDataButton.isEnabled = true
      } else {
        sendDataButton.isEnabled = false
      }
  }
  
  func updateLoopCountLabel() {
    let numStations = scenarioSelected.selfLocations!.count
    let numStepsPerStation = scenarioSelected.subjectAngles!.count
    let currentStation = Int(ceil(Double((currentLoop)/numStepsPerStation))) + 1
    stationNumberLabel.text = currentStation.description + " / " + numStations.description
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
  
  func initScenario() {
    let numPartnerLocations = scenarioSelected.partnerLocations!.count
    let numSelfLocations = scenarioSelected.selfLocations!.count
    let numSubjectAngles = scenarioSelected.subjectAngles!.count
    self.totalNumLoops = numPartnerLocations * numSelfLocations * numSubjectAngles
    
    currentLoop = 0
    updateLoopCountLabel()
    initSequenceList()
    
    receiverPositionValueLabel.text = loopList[0].selfLoc.description
    subjectAngleValueLabel.text = SubjectAngle(rawValue: loopList[0].subjAngle)?.description
  }
  
  func displayNoSendDataMethodsAlert() {
    DispatchQueue.main.async {
      self.statusButton.backgroundColor = UIColor.red
      self.statusButton.blink(enabled: false)
      let alert = UIAlertController(title: "WARNING", message: "No send data methods specified.", preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        print("No send data methods specified")
        UIDevice.current.isProximityMonitoringEnabled = false
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func displayMoveToPositionAlert() {
    DispatchQueue.main.async {
      self.statusButton.backgroundColor = UIColor.red
      self.statusButton.blink(enabled: false)
      let alert = UIAlertController(title: "Move into position", message: "Get into location and subject orientation specified. Then click Start.", preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        print("Continue move into position")
        UIDevice.current.isProximityMonitoringEnabled = false
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func updateNextPositionUI(isRangeDone: Bool, isDone: Bool) {
    print("[updateNextPositionUI]")
    
    if isRangeDone {
      self.startStopButton.setTitle("Resume", for: .normal)
    } else {
      self.startStopButton.setTitle("Wait", for: .normal)
      self.startStopButton.isEnabled = false
    }
    
    self.updateLoopCountLabel()
    
    if isDone {
      self.stationNumberLabel.text = "- DONE -"
    } else {
      self.receiverPositionValueLabel.text = self.loopList[self.currentLoop].selfLoc.description
      self.subjectAngleValueLabel.text = SubjectAngle(rawValue: self.loopList[self.currentLoop].subjAngle)?.description
    }
  }
  
  func updateScene(_ sender: UIButton? = nil, _ dataSentOK: Bool? = false) {
    UIDevice.current.isProximityMonitoringEnabled = false
    switch currentState {
    case .idle:
      print("idle")
      
      if sessionID == "" {
        sessionID = UUID().description
      }
      loopStartTime = Utility.getTimestamp()
      currentState = .loopStarted
      
      DispatchQueue.main.async {
        self.startStopButton.setTitle("Abort", for: .normal)
        self.startStopButton.isEnabled = true
        self.sendDataButton.isEnabled = false
        
        self.statusButton.backgroundColor = UIColor.green
        self.statusButton.blink(enabled: true)
        
        UIDevice.current.isProximityMonitoringEnabled = false
      }
      // Clear sensor and bluetooth data. NOTE: StartRun clears sensor data.
      activateSensors?.scanner.bluetoothData.bluetooth = []
      activateSensors!.startRun(
        range: loopList[currentLoop].selfLoc,
        angle: loopList[currentLoop].subjAngle,
        metaData: metaData,
        scenarioData: scenarioSelected,
        beaconSubjectInfo: beaconSubjectInfo)
      
      
    case .loopStarted:
      print("loopStarted")
      
      // If Start/Abort button was pressed, warn,
      // else must have received end of test signal
      // from activateSensors object
      if sender != nil {
        print("[updateScene | loopStarted] Button pressed")
        currentState = .idle
        print("Test aborted, start over")
        self.activateSensors!.stopRun()
        abortAlert()
      } else {
        print("[updateScene | loopStarted] runToCompletion was triggered")
        
        if currentLoop < totalNumLoops {
          startStopButton.setTitle("Resume", for: .normal)
          updateLoopCountLabel()
        } else {
          startStopButton.setTitle("Done", for: .normal)
        }
        if autoMoveThroughAngles {
          startStopButton.isEnabled = false
        } else {
          startStopButton.isEnabled = true
        }

        setEnabledSendDataButton()
        
        currentState = .loopEnded
        self.statusButton.backgroundColor = UIColor.red
        statusButton.blink(enabled: false)
        
        if autoMoveThroughAngles {
          self.sendDataButton.isEnabled = false
          statusButton.blink(enabled: true)
        }
      }
    case .loopAborted:
      print("loopAborted")
      
    case .loopEnded:
      print("loopEnded")
      
      // let (isRangeDone, isTestDone) = self.getNext()
      let (_, isTestDone) = self.getNext()
      if !isTestDone && autoMoveThroughAngles {
        break
      }
      
      if dataSentOK == true {
        gotoNextLoopOrEnd(isTestDone: isTestDone)
      } 
      
      if self.dataSendMethods.count == 0 {
        // Allow people to play with the app even if they
        // haven't set up send data collection methods
        gotoNextLoopOrEnd(isTestDone: isTestDone)
      }
      
    }
  }
  
  func gotoNextLoopOrEnd(isTestDone: Bool) {
    currentState = .idle
    self.statusButton.backgroundColor = UIColor.red
    statusButton.blink(enabled: false)
    startStopButton.isEnabled = true
    sendDataButton.isEnabled = false
    
    if isTestDone == true {
      print("--------- Done ---------")
      startStopButton.setTitle("Done", for: .normal)
      thankYouAlert()
    }
  }
  
  func initSequenceList() {
    loopList.removeAll()
    if let partnerLocs = scenarioSelected.partnerLocations,
      let selfLocs = scenarioSelected.selfLocations,
      let subjAngles = scenarioSelected.subjectAngles {
      for p in partnerLocs {
        for r in selfLocs {
          for a in subjAngles {
            loopList.append((p, r, a.rawValue))
          }
        }
      }
    }
  }
  
  func nextStationAlert() {
    DispatchQueue.main.async {
      self.statusButton.backgroundColor = UIColor.red
      self.statusButton.blink(enabled: false)
      let alert = UIAlertController(title: "SEND DATA", message: "Full rotation is complete. Send data and continue to next position and angle.", preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        print("[STVC | nextStationAlert] continue")
        UIDevice.current.isProximityMonitoringEnabled = false
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func repositionAlert() {
    DispatchQueue.main.async {
      self.statusButton.backgroundColor = UIColor.red
      let alert = UIAlertController(title: "REPOSITION", message: "Please move according to the locations and angles shown in Step 1", preferredStyle: UIAlertController.Style.alert)
      alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        self.reset()
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
  
  func reset() {
    currentState = .idle
    initUI()
    initScenario()
  }
  
  func resetAutoDone() {
    reset()
    startStopButton.isEnabled = false
    startStopButton.setTitle("Reset", for: .normal)
    startStopButton.backgroundColor = .orange
    
    // sendDataButton.isEnabled = true
    setEnabledSendDataButton()
    sendDataButton.backgroundColor = .orange
  }
  
  // Clean up after sending data or abort
  func resetLog() {
    activateSensors!.deleteLogs()
    activateSensors!.createNewLog()
    resetLoopData()
  }
  
  func resetLoopData() {
    allLoopData = []
    clientServerFormatter = nil
  }
  
  // Returns: (isRangeDone, isTestDone)
  func getNext() -> (isRangeDone: Bool, isTestDone: Bool) {
    var isRangeDone: Bool = false
    var isTestDone: Bool = false
    
    currentLoop += 1
    
    if (currentLoop % totalNumLoops) == 0 {
      isTestDone = true
      currentLoop = 0
    }
    
    // NOTE: assumes only one beacon location
    let numRanges = scenarioSelected.subjectAngles!.count
    if (currentLoop % numRanges) == 0 {
      isRangeDone = true
    }
    
    return (isRangeDone, isTestDone)
  }
  
  func isDone() -> Bool {
    var isDone: Bool = false
    if (currentLoop % totalNumLoops) == 0 {
      isDone = true
    }
    return isDone
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
          if self.currentLoop > 0 && self.currentLoop < self.totalNumLoops {
            self.startStopButton.setTitle("Resume", for: .normal)
          } else {
            self.startStopButton.setTitle("Start", for: .normal)
          }
          self.startStopButton.isEnabled = true
          self.startStopButton.setupRoundedButton()
          self.sendDataButton.isEnabled = false
          self.sendDataButton.setupRoundedButton()
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
      self.startStopButton.isEnabled = true
      break
    case .failed:
      print("Sending mail failed")
      break
    default:
      break
    }
    
    controller.dismiss(animated: true, completion: mailComposeCompletion)
  }
  
  func mailComposeCompletion() {
    if dataSendMethods.contains(.mitllServer) {
      postData()
    } else {
      // Delete old logs, start new one
      resetLog()
    }
  }

  @IBAction func startStopButton_TouchUpInside(_ sender: UIButton) {
    if startStopButton.title(for: .normal) == "Reset" {
      print("[startStopButton_TouchUpInside] Reset, currentState: " + currentState.rawValue.description)
      startStopButton.setTitle("Start", for: .normal)
      startStopButton.isEnabled = true
      reset()
      sessionID = ""
    } else if startStopButton.title(for: .normal) == "Resume" {
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
  
  func postDataSuccessHandler(json: [String:AnyObject]) {
    print("[TLVC | postDataSuccessHandler]")
    resetLog()
  }
  
  func postDataFailureHandler(errMsg: String?) {
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
  
  
  // MARK: Gesture Recognizer
  
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
