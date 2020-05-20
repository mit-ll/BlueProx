//
//  Scenario.swift
//  BlueProx
//
//  Copyright © 2020 Massachusetts Institute of Technology. All rights reserved.
//

import Foundation


class Scenario {
    let frameworkBundleID: String = "edu.mit.blueprox"
    var allScenarios: Array<ScenarioModel> = []
    
    private func readJson() {
        do {
            let frameworkBundle = Bundle(identifier: frameworkBundleID)
            if let file = frameworkBundle?.url(forResource: "scenarios", withExtension: "json") {
                let data = try Data(contentsOf: file)
                do {
                    allScenarios = try JSONDecoder().decode([ScenarioModel].self, from: data)
                    if allScenarios.count > 0 {
                        print(".... \(allScenarios)")
                    } else {
                        print("NO SCENARIOS!!!!")
                    }
                } catch {
                    print(error.localizedDescription)
                    print("Check that the items in scenarios.json are of the proper type. For example, if environment, then what is written in the json file must match the strings in the MultiPathEnvironment enum.")
                }
            }
        } catch {
            print(error.localizedDescription)
            print("Check that the items in scenarios.json are of the proper type. For example, if environment, then what is written in the json file must match the strings in the MultiPathEnvironment enum.")
        }
    }
    
    func getScenarios() -> [ScenarioModel] {
        readJson()
        return allScenarios
    }
    
    func getScenarios(type: TestType) -> [ScenarioModel] {
        readJson()
        var scenarios = allScenarios.filter{$0.type == type}
        let emptyScenario = ScenarioModel(
            name: "- choose one -",
            type: .structured,
            summary: "",
            environmentType: EnvironmentType.unknown,
            environmentDetail: EnvironmentDetail.unknown,
            partnerLocations: nil,
            selfLocations: nil,
            subjectAngles: nil)
        scenarios.insert(emptyScenario, at: 0)
        return scenarios
    }
}
