import UIKit
import Photos

class TestPhotoLibraryChangeViewController: BaseTestViewController {

    private var previousResult: PHFetchResult<PHAsset>?
    private var changeObserver: PhotoLibraryChangeObserver?

    private let logTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        tv.backgroundColor = UIColor(white: 0.1, alpha: 1)
        tv.textColor = .white
        tv.layer.cornerRadius = 8
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "PhotoLibrary 增量监听"

        view.addSubview(logTextView)
        logTextView.frame = CGRect(x: 16, y: 100, width: view.bounds.width - 32, height: view.bounds.height - 150)

        setupObserver()
        saveCurrentState()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            PHPhotoLibrary.shared().unregisterChangeObserver(changeObserver!)
        }
    }

    private func setupObserver() {
        changeObserver = PhotoLibraryChangeObserver { [weak self] changeDetails in
            self?.handlePhotoLibraryChange(changeDetails)
        }
        PHPhotoLibrary.shared().register(changeObserver!)
        log("✅ 已注册相册变化观察者")
        log("⏳ 等待相册变化...\n")
    }

    private func saveCurrentState() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard status == .authorized || status == .limited else {
                self?.log("❌ 相册权限未授权")
                return
            }

            let options = PHFetchOptions()
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let result = PHAsset.fetchAssets(with: .image, options: options)

            self?.previousResult = result

            DispatchQueue.main.async {
                self?.log("📸 已保存当前相册状态，共 \(result.count) 张照片")
            }
        }
    }

    private func handlePhotoLibraryChange(_ changeDetails: PHPhotoLibraryChangeDetails) {
        DispatchQueue.main.async { [weak self] in
            self?.log("\n========== 相册变化检测到 ==========")

            if let inserted = changeDetails.insertedAssetIdentifiers, !inserted.isEmpty {
                self?.log("\n🟢 增加了 \(inserted.count) 张照片:")
                for id in inserted {
                    self?.log("   + \(id)")
                }
            }

            if let deleted = changeDetails.deletedAssetIdentifiers, !deleted.isEmpty {
                self?.log("\n🔴 删除了 \(deleted.count) 张照片:")
                for id in deleted {
                    self?.log("   - \(id)")
                }
            }

            if let changed = changeDetails.changedAssetIdentifiers, !changed.isEmpty {
                self?.log("\n🟡 编辑了 \(changed.count) 张照片:")
                for id in changed {
                    self?.log("   ~ \(id)")
                }
            }

            if let insertedAssets = changeDetails.insertedAssets, !insertedAssets.isEmpty() {
                self?.log("\n🟢 新增照片详情:")
                insertedAssets.enumerateObjects { asset, _, _ in
                    let name = asset.value(forKey: "filename") as? String ?? "未知"
                    self?.log("   + \(name)")
                }
            }

            if let updatedAssets = changeDetails.updatedAssets, !updatedAssets.isEmpty() {
                self?.log("\n🟡 编辑照片详情:")
                updatedAssets.enumerateObjects { asset, _, _ in
                    let name = asset.value(forKey: "filename") as? String ?? "未知"
                    self?.log("   ~ \(name)")
                }
            }

            if let deletedAssets = changeDetails.deletedAssets, !deletedAssets.isEmpty() {
                self?.log("\n🔴 删除照片详情:")
                deletedAssets.enumerateObjects { asset, _, _ in
                    let name = asset.value(forKey: "filename") as? String ?? "未知"
                    self?.log("   - \(name)")
                }
            }

            self?.log("\n===================================\n")

            self?.previousResult = changeDetails.fetchResultAfterChanges
        }
    }

    private func log(_ message: String) {
        logTextView.text += message + "\n"
        let bottom = NSRange(location: logTextView.text.count - 1, length: 1)
        logTextView.scrollRangeToVisible(bottom)
    }

    deinit {
        if changeObserver != nil {
            PHPhotoLibrary.shared().unregisterChangeObserver(changeObserver!)
        }
    }
}

class PhotoLibraryChangeObserver: NSObject, PHPhotoLibraryChangeObserver {
    private let handler: (PHPhotoLibraryChangeDetails) -> Void

    init(handler: @escaping (PHPhotoLibraryChangeDetails) -> Void) {
        self.handler = handler
        super.init()
    }

    func photoLibraryDidChange(_ changeInstance: PHPhotoLibraryChangeDetails) {
        handler(changeInstance)
    }
}