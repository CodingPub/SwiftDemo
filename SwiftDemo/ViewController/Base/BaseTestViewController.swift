//
//  BaseTestViewController.swift
//  SwiftDemo
//
//  Created by Xiaobin Lin on 2019/10/25.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit
import SnapKit

class BaseTestViewController: UIViewController {
    
    var tableView: UITableView!
    var sections: [TestSectionModel]!
    var autoClickIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sections = createSections()
        createViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let indexPath = autoClickIndexPath {
            autoClickIndexPath = nil
            if indexPath.section < self.numberOfSections(in: tableView)
                && indexPath.row < self.tableView(tableView, numberOfRowsInSection: indexPath.section) {
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                tableView(tableView, didSelectRowAt: indexPath)
            }
        }
    }
    
    func createSections() -> [TestSectionModel] {
        return []
    }
    
    func createViews() {
        tableView = createTableView()
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
}

extension BaseTestViewController {
    func itemAtIndexPath(_ indexPath: IndexPath) -> TestCellModel {
        let section = sections[indexPath.section]
        return section.items[indexPath.row]
    }
}

extension BaseTestViewController: UITableViewDataSource, UITableViewDelegate {
    func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCellIDentifier")
        return tableView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCellIDentifier", for: indexPath)
        
        let item = itemAtIndexPath(indexPath)
        cell.textLabel?.text = "\(indexPath.section)-\(indexPath.row) \(item.title)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = itemAtIndexPath(indexPath)
        item.operation()
    }
}
