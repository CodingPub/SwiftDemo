//
//  TestNotificationViewController.swift
//  SwiftDemo
//
//  Created by XiaobinLin on 2019/11/5.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit

class TestNotificationViewController: BaseTestViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .NSExtensionHostDidEnterBackground, object: nil, queue: OperationQueue.main) { (notification) in
            print("程序进入到后台了")
        }
    }
}
