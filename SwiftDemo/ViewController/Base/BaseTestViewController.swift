//
//  BaseTestViewController.swift
//  SwiftDemo
//
//  Created by Xiaobin Lin on 2019/10/25.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import SnapKit
import UIKit

class BaseTestViewController: UIViewController {
    lazy var tableView = createTableView()
    lazy var sections = generateSections()
    var autoClickIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let indexPath = autoClickIndexPath {
            autoClickIndexPath = nil
            if indexPath.section < numberOfSections(in: tableView),
                indexPath.row < tableView(tableView, numberOfRowsInSection: indexPath.section) {
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                tableView(tableView, didSelectRowAt: indexPath)
            }
        }
    }

    func generateSections() -> [TestSectionModel] {
        return []
    }

    func setupViews() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
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

    func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
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

extension BaseTestViewController {
    func pushViewController(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}
