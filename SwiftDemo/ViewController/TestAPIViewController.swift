//
//  TestAPIViewController.swift
//  SwiftDemo
//
//  Created by XiaobinLin on 2019/11/8.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit

class TestAPIViewController: BaseTestViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
#if DEBUG
        #warning("快速测试")
        autoClickIndexPath = IndexPath(row: 0, section: 0)
#endif
    }
    
    override func generateSections() -> [TestSectionModel] {
        return [createTestSection()]
    }

    func createTestSection() -> TestSectionModel {
        var array = [TestCellModel]()

        array.append(TestCellModel(title: "Change size", operation: {
            let size = CGSize(width: 300, height: 400)
            let changeSize = size.applying(CGAffineTransform(scaleX: 0.6, y: 0.8))
            print(changeSize)
            
            let frame = CGRect(x: 10, y: 10, width: 300, height: 400)
            let changeFrame = frame.applying(CGAffineTransform(scaleX: 0.6, y: 0.8))
            print(changeFrame)
        }))

        return TestSectionModel(title: "Test", items: array)
    }

}
