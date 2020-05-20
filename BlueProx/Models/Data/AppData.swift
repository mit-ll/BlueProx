//
//  AppData.swift
//  BlueProx
//

import Foundation


struct AppData: Codable {
  let appName: String
  let appVer: String
  
  enum CodingKeys: String, CodingKey {
    case appName = "app_name"
    case appVer = "app_ver"
  }
  
  init() {
    self.appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
    self.appVer = Bundle.main.fullVersionBuildNumber!
  }
  
}

