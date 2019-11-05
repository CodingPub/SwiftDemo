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
    
    @objc func didEnterBackground(notification: Notification) {
        print("TestNotificationViewController 进入后台")
    }
}

fileprivate extension Selector {
    static let didEnterBackground = #selector(TestNotificationViewController.didEnterBackground)
}
