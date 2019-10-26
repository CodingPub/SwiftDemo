//
//  TestSectionModel.swift
//  SwiftDemo
//
//  Created by Xiaobin Lin on 2019/10/25.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit

class TestSectionModel: NSObject {
    var title: String
    var items: [TestCellModel]
    
    init(title: String, items: [TestCellModel]) {
        self.title = title
        self.items = items
    }
}
