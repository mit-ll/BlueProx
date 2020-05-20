//
//  ConfigureScenarioSetupViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit

class ScenarioChooserSetupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
  
  
  // MARK: Properties
  
  fileprivate let typePickerView = ToolbarPickerView()
  var typePickerData: [String] = []
  private var typeSelected: String = "- choose one -"
  
  fileprivate let scenarioPickerView = ToolbarPickerView()
  var scenarioPickerData: [String] = []
  private var scenarios: [ScenarioModel] = []
  private var scenarioSelected: ScenarioModel = ScenarioModel()
  
  @IBOutlet weak var typeTextField: UITextField!
  @IBOutlet weak var scenarioTextField: UITextField!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var scenarioLabel: UILabel!
  @IBOutlet weak var nextButton: UIButton!
  
  
  // MARK: UIViewController overrides
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Test Type
    typeTextField.delegate = self
    typePickerData = TestType.allCases.map { $0.rawValue }
    
    // DEVELOPER: NOTE: Selectively remove an item from
    // the test type picker view.
    // typePickerData = typePickerData.filter{ $0 != "Free Form" }
    
    createTypePickerView()
    
    // Scenario
    // Populate the pulldown from the scenarios.json data file.
    scenarioTextField.delegate = self
    scenarioLabel.isEnabled = false
    scenarioTextField.isEnabled = false
    createScenarioPickerView()
    scenarioTextField.isEnabled = false

    nextButton.setupRoundedButton()
    nextButton.isEnabled = false
    
    // set default value
    pickerView(typePickerView, didSelectRow: 0, inComponent: 0)
    pickerView(scenarioPickerView, didSelectRow: 0, inComponent: 0)
    
    // Put this in all configuration setup view
    // controllers
    initMoveViewWithKeyboard()
  }
  
  // MARK: - Navigation
  
  // Send selected scenario name to CustomScenarioViewController
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // NOTE: Restructured so all TestTypes now segue through
    // the same setup vcs.
    if segue.identifier == "DeviceSetupViewController" {
      let vc = segue.destination as! DeviceSetupViewController
      vc.scenarioSelected = self.scenarioSelected
      vc.typeSelected = TestType(rawValue: typeSelected)!
    } else if segue.identifier == "SituationalUserSetupViewController" {
      let vc = segue.destination as! SituationalUserSetupViewController
      vc.scenarioSelected = self.scenarioSelected
      vc.typeSelected = TestType(rawValue: typeSelected)!
      // First time into the SituationalUserSetupViewController,
      // role is Partner
      vc.roleSelected = "Partner"
    }
  }
  
  @IBAction func nextButton_TouchUpInside(_ sender: UIButton) {
    switch TestType(rawValue: typeSelected) {
    case .none:
      print("[next] type: none")
    case .free_form:
      self.performSegue(withIdentifier: "DeviceSetupViewController", sender: self)
     case .structured:
      self.performSegue(withIdentifier: "DeviceSetupViewController", sender: self)
    case .situational:
      self.performSegue(withIdentifier: "SituationalUserSetupViewController", sender: self)
    case .some(.none):
      print("[next]TODO: invalid test type")
    }
  }
  
  // MARK: Conform to UITextField
  
  // Dismiss keyboard when touching outside of keyboard/entry area
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
    super.touchesBegan(touches, with: event)
  }
  
  
  // MARK: Picker view related - Conform to UIPickerView
  
  // Number of columns of data
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  // Number of rows of data
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    var count = 0
    if pickerView == typePickerView {
      count = typePickerData.count
    } else if pickerView == scenarioPickerView {
      count = scenarioPickerData.count
    }
    
    return count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    var msg = ""
    if pickerView == typePickerView {
      msg = typePickerData[row]
    } else if pickerView == scenarioPickerView {
      msg = scenarioPickerData[row]
    }
    
    return msg
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if pickerView == typePickerView {
      descriptionTextView.text = ""
      typeSelected = typePickerData[row]
      typeTextField.text = typeSelected
      
      populateScenarioData()
      updateEnabled()

      scenarioTextField.text = "- choose one -"
      
    } else if pickerView == scenarioPickerView {
      descriptionTextView.text = ""
      let name = scenarioPickerData[row]
      scenarioSelected = scenarios.filter{$0.name == name}[0]
      scenarioTextField.text = scenarioSelected.name
      if scenarioSelected.name != "- choose one -" {
        switch TestType(rawValue: typeSelected) {
        case .free_form:
          fallthrough
        case .situational:
          descriptionTextView.text = "Selected Test Summary: \n\n" + scenarioSelected.shortDescription
        case .structured:
          descriptionTextView.text = "Selected Test Summary: \n\n" + scenarioSelected.description
        case .none:
          descriptionTextView.text = "Selected Test Summary: \n\n" + scenarioSelected.shortDescription
        case .some(.none):
          descriptionTextView.text = ""
        }
      }
      
      updateEnabled()
    }
  }
  
  // MARK: Methods
  
  private func populateScenarioData() {
    let sc = Scenario()
    scenarios = sc.getScenarios()
    let typeSelectedAsType = TestType(rawValue: typeSelected)
    scenarios = sc.getScenarios(type: typeSelectedAsType!)
    scenarioPickerData = scenarios.map{$0.name}
  }
  
  
  // MARK: UI Methods
  func createTypePickerView() {
    self.typeTextField.inputView = self.typePickerView
    self.typeTextField.inputAccessoryView = self.typePickerView.toolbar
    
    self.typePickerView.dataSource = self
    self.typePickerView.delegate = self
    self.typePickerView.toolbarDelegate = self
    
    self.typePickerView.reloadAllComponents()
  }
  
  func createScenarioPickerView() {
    self.scenarioTextField.inputView = self.scenarioPickerView
    self.scenarioTextField.inputAccessoryView = self.scenarioPickerView.toolbar
    
    self.scenarioPickerView.dataSource = self
    self.scenarioPickerView.delegate = self
    self.scenarioPickerView.toolbarDelegate = self
    
    self.scenarioPickerView.selectedRow(inComponent: 0)
    self.scenarioPickerView.reloadAllComponents()
  }
  
  
  // MARK: Conform to UITextField
  // Disable editing the text fields (only allow changing from the pickers)
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return false
  }
  
}


extension ScenarioChooserSetupViewController: ToolbarPickerViewDelegate {
  
  func didTapDone(_ sender: UIPickerView) {
    if sender == typePickerView {
      let row = self.typePickerView.selectedRow(inComponent: 0)
      self.typePickerView.selectRow(row, inComponent: 0, animated: false)
      self.typeTextField.resignFirstResponder()
    } else if sender == scenarioPickerView {
      let row = self.scenarioPickerView.selectedRow(inComponent: 0)
      self.scenarioPickerView.selectRow(row, inComponent: 0, animated: false)
      self.scenarioTextField.resignFirstResponder()
    }
    
    if (typeTextField.text == "- choose one -") ||
       (scenarioTextField.text == "- choose one -") {
      nextButton.isEnabled = false
    } else {
      nextButton.isEnabled = true
    }

  }
  
  func updateEnabled() {
    if (typeTextField.text == "- choose one -")  {
      scenarioTextField.text = "- choose one -"
      scenarioPickerView.selectRow(0, inComponent: 0, animated: true)
      scenarioLabel.isEnabled = false
      scenarioTextField.isEnabled = false
      nextButton.isEnabled = false
    } else {
      scenarioLabel.isEnabled = true
      scenarioTextField.isEnabled = true
      nextButton.isEnabled = false
    }
    
    if (scenarioTextField.text == "- choose one -") {
      nextButton.isEnabled = false
    } else {
      nextButton.isEnabled = true
    }
  }
  
  func didTapCancel(_ sender: UIPickerView) {
    self.typeTextField.text = nil
    self.descriptionTextView.text = nil
    self.typeTextField.resignFirstResponder()
    
    self.scenarioTextField.text = nil
    self.descriptionTextView.text = nil
    self.scenarioTextField.resignFirstResponder()
    
    updateEnabled()
  }
}
