//
//  TestModelViewController.swift
//  SwiftDemo
//
//  Created by Xiaobin Lin on 2019/10/26.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit

class TestModelViewController: BaseTestViewController {

    deinit {
        print("\(self) deinit")
    }
    
    override func generateSections() -> [TestSectionModel] {
        return [createTestSection()]
    }
    
    func createTestSection() -> TestSectionModel {
        var array = [TestCellModel]()
        
        array.append(TestCellModel(title: "simpleDict2Model", operation: { [weak self] in
            guard let self = self else { return }
            
            self.simpleDict2Model()
        }))
        
        return TestSectionModel(title: "Test", items: array)
    }
    
    func simpleDict2Model() {
        let dict = ["name":"Jack","icon":"lufy.png"]
        let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
        if let user = try? JSONDecoder().decode(User.self, from: data) {
             print("\(user)")
        } else {
            print("error")
        }
    }
}

class User: NSObject, Codable {
    var name:String?
    var icon:String?
    
    override internal var description: String {
        return "name: \(String(describing: name))\nicon: \(String(describing: icon)) \n"
    }
}
