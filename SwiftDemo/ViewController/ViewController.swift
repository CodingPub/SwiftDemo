//
//  ViewController.swift
//  SwiftDemo
//
//  Created by Xiaobin Lin on 2019/10/25.
//  Copyright © 2019 Xiaobin Lin. All rights reserved.
//

import UIKit
import Photos

class ViewController: BaseTestViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: .didEnterBackground, name: UIApplication.didEnterBackgroundNotification, object: nil)

        #if true
            #warning("快速测试")
            autoClickIndexPath = IndexPath(row: 0, section: 0)
        #endif
    }

    override func generateSections() -> [TestSectionModel] {
        return [createTestSection()]
    }

    func createTestSection() -> TestSectionModel {
        var array = [TestCellModel]()

        array.append(TestCellModel(title: "Test Photo Album List", operation: { [weak self] in
            guard let self = self else { return }
            let ctrl = TestPhotoAlbumListViewController()
            self.pushViewController(ctrl)
        }))

        array.append(TestCellModel(title: "Test Photo Album Query", operation: { [weak self] in
            guard let self = self else { return }
            self.testPhotoAlbumQuery()
        }))

        array.append(TestCellModel(title: "Test PhotoAlbum Incremental", operation: { [weak self] in
            guard let self = self else { return }
            let ctrl = TestPhotoAlbumIncrementalViewController()
            self.pushViewController(ctrl)
        }))

        array.insert(TestCellModel(title: "Test Photo Album Query (Filtered)", operation: { [weak self] in
            guard let self = self else { return }
            self.testPhotoAlbumQueryFiltered()
        }), at: 1)

        array.append(TestCellModel(title: "Test NSMapTable", operation: { [weak self] in
            guard let self = self else { return }
            self.testNSMapTable()
        }))

        array.append(TestCellModel(title: "Test Model", operation: { [weak self] in
            guard let self = self else { return }

            let ctrl = TestModelViewController()
            self.pushViewController(ctrl)
        }))

        array.append(TestCellModel(title: "Test Notification", operation: { [weak self] in
            guard let self = self else { return }

            let ctrl = TestNotificationViewController()
            self.pushViewController(ctrl)
        }))
        
        array.append(TestCellModel(title: "Test Weak", operation: { [weak self] in
            guard let self = self else { return }

            let ctrl = TestWeakViewController()
            self.pushViewController(ctrl)
        }))
        
        array.append(TestCellModel(title: "Test API", operation: { [weak self] in
            guard let self = self else { return }

            let ctrl = TestAPIViewController()
            self.pushViewController(ctrl)
        }))
        
        array.append(TestCellModel(title: "BezierPath", operation: { [weak self] in
            guard let self = self else { return }

            let ctrl = TestBezierPathViewController()
            self.pushViewController(ctrl)
        }))

        return TestSectionModel(title: "Test", items: array)
    }

    // MARK: - 相册刷新测试
    private func testPhotoAlbumRefresh() {
        print("\n=== PhotoAlbum 刷新测试 ===")

        let hasLastFetchResult = UserDefaults.standard.object(forKey: "lastAssetIdentifiers") != nil

        if hasLastFetchResult {
            print("检测到历史记录，对比变化...")
            verifyChanges()
        } else {
            print("首次运行，保存当前相册状态...")
            saveCurrentFetchResult()
        }
    }

    private func saveCurrentFetchResult() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard status == .authorized || status == .limited else {
                print("  ❌ 相册权限未授权")
                return
            }

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            var assets: [AssetInfo] = []
            result.enumerateObjects { asset, _, _ in
                let name = asset.value(forKey: "filename") as? String ?? "未知"
                assets.append(AssetInfo(id: asset.localIdentifier, modificationDate: asset.modificationDate, name: name))
            }

            if let data = try? JSONEncoder().encode(assets) {
                UserDefaults.standard.set(data, forKey: "lastAssetIdentifiers")
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastSaveTime")
                print("  ✅ 已保存当前相册状态，共 \(result.count) 张照片")
            }
        }
    }

    private func verifyChanges() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard status == .authorized || status == .limited else {
                print("  ❌ 相册权限未授权")
                return
            }

            guard let self = self else { return }

            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let currentResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            var currentAssets: [AssetInfo] = []
            currentResult.enumerateObjects { asset, _, _ in
                let name = asset.value(forKey: "filename") as? String ?? "未知"
                currentAssets.append(AssetInfo(id: asset.localIdentifier, modificationDate: asset.modificationDate, name: name))
            }

            let currentIds = Set(currentAssets.map { $0.id })
            let currentDict = Dictionary(uniqueKeysWithValues: currentAssets.map { ($0.id, $0) })

            guard let lastData = UserDefaults.standard.data(forKey: "lastAssetIdentifiers"),
                  let lastAssets = try? JSONDecoder().decode([AssetInfo].self, from: lastData) else {
                print("  ❌ 无法读取历史记录")
                return
            }

            let lastIds = Set(lastAssets.map { $0.id })
            let lastDict = Dictionary(uniqueKeysWithValues: lastAssets.map { ($0.id, $0) })

            print("\n  📊 对比结果:")
            print("  上次保存时间: \(Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "lastSaveTime")))")
            print("  上次照片数量: \(lastAssets.count)")
            print("  当前照片数量: \(currentAssets.count)")

            let addedIds = currentIds.subtracting(lastIds)
            let deletedIds = lastIds.subtracting(currentIds)
            let commonIds = currentIds.intersection(lastIds)

            var editedNames: [String] = []
            for id in commonIds {
                if let current = currentDict[id], let last = lastDict[id] {
                    if current.modificationDate != last.modificationDate || current.name != last.name {
                        editedNames.append(current.name)
                    }
                }
            }

            print("\n  🟢 增加了 \(addedIds.count) 张照片:")
            for id in addedIds {
                if let asset = currentDict[id] {
                    print("    + \(asset.name)")
                }
            }

            print("\n  🔴 删除了 \(deletedIds.count) 张照片:")
            for id in deletedIds {
                if let asset = lastDict[id] {
                    print("    - \(asset.name)")
                }
            }

            print("\n  🟡 编辑了 \(editedNames.count) 张照片:")
            for name in editedNames {
                print("    ~ \(name)")
            }

            if addedIds.isEmpty && deletedIds.isEmpty && editedNames.isEmpty {
                print("\n  ⚪ 照片没有变化")
                print("\n  💡 提示: 请在相册中增删改照片后再次运行测试")
            }

            self.saveCurrentFetchResult()
        }
    }

    private func testPhotoAlbumQuery() {
        print("\n=== 相册列表查询测试 ===")
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                print("❌ 没有相册权限")
                return
            }

            DispatchQueue.main.async {
                let options = PHFetchOptions()
                
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                options.predicate = NSPredicate(format: "isFavorite == NO")
                
                options.fetchLimit = 10

                let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
                
                print("查询到 \(fetchResult.count) 张未收藏的图片")
                print("前10张图片的 localIdentifier:")
                
                fetchResult.enumerateObjects { asset, index, _ in
                    print("  \(index + 1). \(asset.localIdentifier)")
                }
            }
        }
    }

    private func testPhotoAlbumQueryFiltered() {
        print("\n=== 相册列表查询测试（过滤特定ID）===")
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                print("❌ 没有相册权限")
                return
            }

            DispatchQueue.main.async {
                let excludedIds = [
                    "5202B8EE-B6FF-4B00-8FE3-15D5628DD289/L0/001",
                    "6340C460-ED9A-462A-A5A6-3AFC7468DAF3/L0/001"
                ]
                
                let options = PHFetchOptions()
                
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                options.predicate = NSPredicate(format: "NOT (%K IN %@) AND isFavorite == NO", "localIdentifier", excludedIds)
                
                options.fetchLimit = 10

                let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
                
                print("查询到 \(fetchResult.count) 张未收藏且不在排除列表的图片")
                print("前10张图片的 localIdentifier:")
                
                fetchResult.enumerateObjects { asset, index, _ in
                    print("  \(index + 1). \(asset.localIdentifier)")
                }
            }
        }
    }

    private struct AssetInfo: Codable {
        let id: String
        let modificationDate: Date?
        let name: String
    }

    // MARK: - NSMapTable 测试

    class TestObject {
        let name: String
        var deinitCalled = false

        init(name: String) {
            self.name = name
        }

        deinit {
            deinitCalled = true
            print("\(name) 被释放")
        }
    }

    private func testNSMapTable() {
        print("=== NSMapTable 内存管理测试 ===\n")

        // 测试1: Key 释放后，Value 也会被释放
        print("测试1: Key 释放后，Value 也会被释放")
        testKeyReleaseValueRelease()

        // 测试2: Value 释放后，Key 也会被释放
        print("\n测试2: Value 释放后，Key 也会被释放")
        testValueReleaseKeyRelease()

        // 测试3: 存储 Int 类型
        print("\n测试3: 存储 Int 类型")
        testIntStorage()
    }

    private func testIntStorage() {
        let mapTable = NSMapTable<NSString, NSNumber>.strongToStrongObjects()

        // 存储 Int（会自动装箱为 NSNumber）
        mapTable.setObject(NSNumber(value: 100), forKey: "intKey" as NSString)
        mapTable.setObject(NSNumber(value: 200), forKey: "intKey2" as NSString)

        // 读取 Int
        if let value = mapTable.object(forKey: "intKey" as NSString) {
            print("  读取 intKey: \(value.intValue)")
        }

        // 直接用 Int 的方式（需要转换）
        if let value = mapTable.object(forKey: "intKey2" as NSString) {
            print("  读取 intKey2: \(value.intValue)")
        }

        print("  count = \(mapTable.count)")

        // 遍历所有 key-value
        print("  遍历所有条目:")
        var keyEnum: NSEnumerator? = mapTable.keyEnumerator()
        while let key = keyEnum?.nextObject() as? NSString {
            if let value = mapTable.object(forKey: key) {
                print("    \(key) -> \(value.intValue)")
            }
        }

        print("  ✅ Int 类型可以正常存储（需要转换为 NSNumber）")
    }

    private func testKeyReleaseValueRelease() {
        print("=== 测试1: Key 释放后，Value 也被清理 ===")

        // 创建弱引用映射表
        let mapTable = NSMapTable<AnyObject, AnyObject>.weakToWeakObjects()

        // 阶段1: 创建并插入对象
        withExtendedLifetime((TestObject(name: "Key对象"), TestObject(name: "Value对象"))) { key, value in
            mapTable.setObject(value as AnyObject, forKey: key as AnyObject)
            print("  插入对象后: mapTable count = \(mapTable.count)")
        }

        // 阶段2: 插入新对象（此时旧对象已超出生命周期，应该被清理）
        withExtendedLifetime((NSString(string: "newKey"), NSString(string: "newValue"))) { newKey, newValue in
            mapTable.setObject(newValue, forKey: newKey)
        }

        // 检查 keys 和 values 数量
        var keyCount = 0
        var valueCount = 0

        var keyEnum: NSEnumerator? = mapTable.keyEnumerator()
        while keyEnum?.nextObject() != nil {
            keyCount += 1
        }

        var valueEnum: NSEnumerator? = mapTable.objectEnumerator()
        while valueEnum?.nextObject() != nil {
            valueCount += 1
        }

        print("  mapTable.count = \(mapTable.count), keys = \(keyCount), values = \(valueCount)")

        // 弱引用正常工作：虽然 count 可能显示 2（延迟清理），但实际有效的 keys/values 只有 1
        if keyCount == 1 && valueCount == 1 {
            print("  ✅ 测试通过: 弱引用正常工作（key/value 都被正确清理）")
        } else {
            print("  ❌ 测试失败: keyCount=\(keyCount), valueCount=\(valueCount)")
        }
    }

    private func testValueReleaseKeyRelease() {
        print("\n=== 测试2: Value 释放后，Key 也被清理 ===")

        // 创建弱引用映射表
        let mapTable = NSMapTable<AnyObject, AnyObject>.weakToWeakObjects()

        // 阶段1: 创建并插入对象
        withExtendedLifetime((TestObject(name: "Key对象2"), TestObject(name: "Value对象2"))) { key, value in
            mapTable.setObject(value as AnyObject, forKey: key as AnyObject)
            print("  插入对象后: mapTable count = \(mapTable.count)")
        }

        // 阶段2: 插入新对象（此时旧对象已超出生命周期，应该被清理）
        withExtendedLifetime((NSString(string: "newKey2"), NSString(string: "newValue2"))) { newKey, newValue in
            mapTable.setObject(newValue, forKey: newKey)
        }

        // 检查 keys 和 values 数量
        var keyCount = 0
        var valueCount = 0

        var keyEnum: NSEnumerator? = mapTable.keyEnumerator()
        while keyEnum?.nextObject() != nil {
            keyCount += 1
        }

        var valueEnum: NSEnumerator? = mapTable.objectEnumerator()
        while valueEnum?.nextObject() != nil {
            valueCount += 1
        }

        print("  mapTable.count = \(mapTable.count), keys = \(keyCount), values = \(valueCount)")

        // 弱引用正常工作：虽然 count 可能显示 2（延迟清理），但实际有效的 keys/values 只有 1
        if keyCount == 1 && valueCount == 1 {
            print("  ✅ 测试通过: 弱引用正常工作（key/value 都被正确清理）")
        } else {
            print("  ❌ 测试失败: keyCount=\(keyCount), valueCount=\(valueCount)")
        }
    }

    @objc func didEnterBackground(notification _: Notification) {
        print("ViewController 进入后台")
    }
}

private extension Selector {
    static let didEnterBackground = #selector(ViewController.didEnterBackground)
}
