//
//  TestCellModel.swift
//  SwiftDemo
//
//  Created by Xiaobin Lin on 2019/10/25.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit

typealias TestBlock = () -> Void

class TestCellModel: NSObject {
    var title: String
    var operation: TestBlock
    
    init(title: String, operation: @escaping TestBlock) {
        self.title = title
        self.operation = operation
    }
}
