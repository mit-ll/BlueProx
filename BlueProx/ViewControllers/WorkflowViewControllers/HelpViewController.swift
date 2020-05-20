//
//  HelpViewController.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import UIKit
import MessageUI


class HelpViewController: UIViewController, MFMailComposeViewControllerDelegate {
  
  // MARK: Properties
  
  let contactUsEmails: [String] = ["bluetooth-proximity-admin@mit.edu"]
  
  // UI Properties
  
  @IBOutlet weak var releaseVersionLabel: UILabel!
  
  
  // MARK: UIViewController Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()

    releaseVersionLabel.text = Bundle.main.fullVersionBuildNumber
  }
  
  
  // MARK: Methods
  
  func sendEmail() {
    print("Mailing to : " + contactUsEmails[0])
    let bodyMessage = "Feedback bluetooth-proximity"
    if MFMailComposeViewController.canSendMail() {
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self;
      mail.setToRecipients(contactUsEmails)
      mail.setSubject("ContactUs - bluetooth-proximity")
      mail.setMessageBody(bodyMessage, isHTML: false)
      self.present(mail, animated: true, completion: nil)
    } else {
      print("Mail services not enabled ... are you running from the simulator? Can only e-mail from actual device.")
      DispatchQueue.main.async {
        // Abort alert
        let alert = UIAlertController(title: "FAILURE", message: "Mail services not enabled.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
          print("Continue - mail services not enabled.")
        }))
        self.present(alert, animated: true, completion: nil)
      }
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
    print("[mailComposeCompletion]")
  }

  
  // MARK: Actions
  
  @IBAction func contactUsButton_TouchUpInside(_ sender: UIButton) {
    sendEmail()
  }
  
}
