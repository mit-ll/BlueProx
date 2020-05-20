//
//  ConfigureFreeFormViewController.swift
//  BluetoothProximity
//
//  Created by Stacy Zeder on 4/17/20.
//  Copyright © 2020 Michael Wentz. All rights reserved.
//

import UIKit

class ConfigureFreeFormViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    
    // MARK: Properties
    
    fileprivate let envPickerView = ToolbarPickerView()
    var envPickerData: [String] = []
    private var envSelected: String = ""
    
    
    @IBOutlet weak var envTextField: UITextField!
    @IBOutlet weak var twoPhonesSwitch: UISwitch!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    // MARK: UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Environment
        envTextField.delegate = self
        envPickerData = MultiPathEnvironment.allCases.map { $0.rawValue }
        createEnvPickerView()
    }
    
    
    // MARK: - Navigation
    

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
      count = envPickerData.count
      
      return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
      var msg = ""
        msg = envPickerData[row]
      
      return msg
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        envSelected = envPickerData[row]
        envTextField.text = envSelected
    }
    
    
    // MARK: Methods
    
    // MARK: UI Methods
    func createEnvPickerView() {
      self.envTextField.inputView = self.envPickerView
      self.envTextField.inputAccessoryView = self.envPickerView.toolbar
      
      self.envPickerView.dataSource = self
      self.envPickerView.delegate = self
      self.envPickerView.toolbarDelegate = self
      
      self.envPickerView.reloadAllComponents()
    }

    // MARK: Conform to UITextField
    // Disable editing the text fields (only allow changing from the pickers)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      return false
    }
    
    
    // MARK: Actions
    @IBAction func twoPhonesSwitch_ValueChanged(_ sender: UISwitch) {
        
        // TODO: slz:
        // if switch disabled, continue to run scene
        // if switch enabled, continue to phones scene
    }
    
    @IBAction func nextButton_TouchUpInside(_ sender: UIButton) {
        
        if twoPhonesSwitch.isOn {
            self.performSegue(withIdentifier: "StructuredDeviceSetupViewController", sender: self)
        } else {
            self.performSegue(withIdentifier: "ConfigureFreeFormViewController", sender: self)
        }
    }
    
}

extension ConfigureFreeFormViewController: ToolbarPickerViewDelegate {
  
  func didTapDone() {
    let row = self.envPickerView.selectedRow(inComponent: 0)
    self.envPickerView.selectRow(row, inComponent: 0, animated: false)
    self.envTextField.resignFirstResponder()
  }
  
  func didTapCancel() {
    self.envTextField.text = nil
    self.envTextField.resignFirstResponder()
  }
}
