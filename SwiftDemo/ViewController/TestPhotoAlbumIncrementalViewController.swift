//
//  TestPhotoAlbumIncrementalViewController.swift
//  SwiftDemo
//
//  Created by XiaobinLin on 2026/05/27.
//  Copyright © 2026 Xiaobin Lin. All rights reserved.
//

import UIKit
import Photos

class TestPhotoAlbumIncrementalViewController: BaseTestViewController {

    private let tokenKey = "PersistentChangeTokenKey"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PhotoAlbum Incremental"
    }

    override func generateSections() -> [TestSectionModel] {
        return [createTestSection()]
    }

    func createTestSection() -> TestSectionModel {
        var array = [TestCellModel]()

        array.append(TestCellModel(title: "查询历史变化", operation: { [weak self] in
            guard let self = self else { return }
            self.queryHistoricalChanges()
        }))

        array.append(TestCellModel(title: "在相册中增删改照片", operation: {
            print("\n💡 提示: 请切换到系统相册 App 进行以下操作:")
            print("   1. 添加新照片")
            print("   2. 删除照片")
            print("   3. 编辑照片")
            print("   操作完成后回到此 App 点击「查询历史变化」")
        }))

        array.append(TestCellModel(title: "清除状态", operation: { [weak self] in
            guard let self = self else { return }
            self.clearState()
        }))

        return TestSectionModel(title: "PHPersistentChangeToken", items: array)
    }

    @available(iOS 16.0, *)
    private func queryHistoricalChanges() {
        let lastToken = loadTokenFromDisk()

        if lastToken == nil {
            let currentToken = PHPhotoLibrary.shared().currentChangeToken
            saveTokenToDisk(currentToken)
            print("✅ 首次运行，已保存 Token")
            print("   Token: \(currentToken)")
            print("   请在相册中增删改照片，然后再次点击「查询历史变化」")
            return
        }

        print("\n=== 查询历史变化 ===")
        print("Token: \(lastToken!)")

        do {
            let changes = try PHPhotoLibrary.shared().fetchPersistentChanges(since: lastToken!)

            var changesByAsset: [String: Int] = [:]
            var newToken: PHPersistentChangeToken?

            for change in changes {
                if let persistentChange = change as? PHPersistentChange {
                    newToken = persistentChange.changeToken

                    if let details = try? persistentChange.changeDetails(for: PHObjectType.asset) {
                        for localID in details.insertedLocalIdentifiers {
                            changesByAsset[localID] = 1
                        }

                        for localID in details.updatedLocalIdentifiers {
                            if changesByAsset[localID] == nil {
                                changesByAsset[localID] = 2
                            }
                        }

                        for localID in details.deletedLocalIdentifiers {
                            if changesByAsset[localID] == nil {
                                changesByAsset[localID] = 3
                            }
                        }
                    }
                }
            }

            for (identifier, type) in changesByAsset {
                switch type {
                case 1:
                    print("🟢 新增照片, ID: \(identifier)")
                case 2:
                    print("🟡 修改照片, ID: \(identifier)")
                case 3:
                    print("🔴 删除照片, ID: \(identifier)")
                default:
                    break
                }
            }

            if changesByAsset.isEmpty {
                print("   ⚪ 没有检测到变化")
            }

            if let token = newToken {
                saveTokenToDisk(token)
                print("\n✅ Token 已自动更新")
            }

        } catch {
            print("❌ 查询变化失败: \(error)")
            UserDefaults.standard.removeObject(forKey: tokenKey)
        }
    }

    private func clearState() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        print("✅ 已清除状态")
    }

    @available(iOS 16.0, *)
    private func loadTokenFromDisk() -> PHPersistentChangeToken? {
        guard let lastTokenData = UserDefaults.standard.data(forKey: tokenKey),
              let lastToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: PHPersistentChangeToken.self, from: lastTokenData) else {
            return nil
        }
        return lastToken
    }

    @available(iOS 16.0, *)
    private func saveTokenToDisk(_ token: PHPersistentChangeToken) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: tokenKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("❌ 保存 Token 失败: \(error)")
        }
    }
}
