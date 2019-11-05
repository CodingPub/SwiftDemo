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
        
        NotificationCenter.default.addObserver(self, selector: .didEnterBackground, name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        #if true
        #warning("快速测试")
        autoClickIndexPath = IndexPath(row: 1, section: 0)
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
            self.pushViewController(ctrl)
        }))
        
        array.append(TestCellModel(title: "Test Notification", operation: {
            let ctrl = TestNotificationViewController()
            self.pushViewController(ctrl)
        }))
        
        return TestSectionModel(title: "Test", items: array)
    }
    
    @objc func didEnterBackground(notification: Notification) {
        print("ViewController 进入后台")
    }
}

fileprivate extension Selector {
    static let didEnterBackground = #selector(ViewController.didEnterBackground)
}
