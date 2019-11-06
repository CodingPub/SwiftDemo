//
//  TestNotificationViewController.swift
//  SwiftDemo
//
//  Created by XiaobinLin on 2019/11/5.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit

class TestNotificationViewController: BaseTestViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: .didEnterBackground, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func generateSections() -> [TestSectionModel] {
        return [createTestSection()]
    }
    
    func createTestSection() -> TestSectionModel {
        var array = [TestCellModel]()
        
        array.append(TestCellModel(title: "监听自定义通知", operation: { [weak self] in
            guard let self = self else { return }
            
            NotificationCenter.default.addObserver(self, selector: .receiveCustomNotification, name: .CustomNotification, object: nil)
        }))
        
        array.append(TestCellModel(title: "移除自定义通知", operation: { [weak self] in
            guard let self = self else { return }
            
            NotificationCenter.default.removeObserver(self, name: .CustomNotification, object: nil);
        }))
        
        array.append(TestCellModel(title: "发送自定义通知", operation: {
            NotificationCenter.default.post(name: .CustomNotification, object: nil);
        }))
        
        return TestSectionModel(title: "Test", items: array)
    }
    
    @objc func didEnterBackground(notification: Notification) {
        print("TestNotificationViewController 进入后台")
    }
    
    @objc func receiveCustomNotification(_ notification: Notification) {
        print("收到通知: \(notification)")
    }
    
}

fileprivate extension Selector {
    static let didEnterBackground = #selector(TestNotificationViewController.didEnterBackground)
    static let receiveCustomNotification = #selector(TestNotificationViewController.receiveCustomNotification)
}

extension Notification.Name {
    static let CustomNotification = Notification.Name("CustomNotification")
}

