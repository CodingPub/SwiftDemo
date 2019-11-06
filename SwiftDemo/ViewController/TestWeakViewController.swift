//
//  TestWeakViewController.swift
//  SwiftDemo
//
//  Created by XiaobinLin on 2019/11/6.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit

class TestWeakViewController: BaseTestViewController {
    let manager = Manager()

    deinit {
        print("\(self) deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.foo { [weak self] in
            guard let self = self else { return }

            self.doSomething()
        }
    }

    func doSomething() {
        print("did finish")
    }
}

class Manager {
    var block: TestBlock?

    func foo(block: @escaping TestBlock) {
        self.block = block

        let t = DispatchTime.now() + 2
        DispatchQueue.global().asyncAfter(deadline: t) {
            self.callback()
        }
    }

    func callback() {
        block?()
    }
}
