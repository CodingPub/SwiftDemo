//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Xiaobin Lin on 2019/10/25.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit

class ViewController: BaseTestViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if true
        #warning("快速测试")
        autoClickIndexPath = IndexPath(row: 0, section: 0)
        #endif
    }
    
    override func generateSections() -> [TestSectionModel] {
        var sections = [TestSectionModel]()
        
        sections.append(createTestSection())
        
        return sections
    }
    
    func createTestSection() -> TestSectionModel {
        var array = [TestCellModel]()
        
        array.append(TestCellModel(title: "Test Model", operation: {
            let ctrl = TestModelViewController()
            pushViewController(ctrl)
        }))
        
        array.append(TestCellModel(title: "Test Notification", operation: {
            let ctrl = TestNotificationViewController()
            pushViewController(ctrl)
        }))
        
        return TestSectionModel(title: "Test", items: array)
    }
}
