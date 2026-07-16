//
//  TestPhotoAlbumListViewController.swift
//  SwiftDemo
//
//  Created by Xiaobin Lin on 2026/07/02.
//  Copyright © 2026 Xiaobin Lin. All rights reserved.
//

import UIKit
import Photos

struct DateSection {
    let date: Date
    let dateString: String
    let assets: [PHAsset]
}

class TestPhotoAlbumListViewController: UIViewController {
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var dateSections = [DateSection]()
    
    private let imageManager: PHImageManager = {
        let manager = PHImageManager()
//        manager.allowsCachingHighQualityImages = true
        return manager
    }()
    
    private var prefetchRequests = [IndexPath: PHImageRequestID]()
    
    private let imageSize = CGSize(width: 133*2, height: 133*2)
    private let highPriorityQueue = DispatchQueue(label: "com.swiftDemo.photoQueue", qos: .userInteractive, attributes: .concurrent)
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Album List"
        view.backgroundColor = .white
        
        setupCollectionView()
        fetchPhotos()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (UIScreen.main.bounds.width - 20 - 2 * 8) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 44)
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.register(DateHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DateHeader")
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    private func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else { return }
            
            DispatchQueue.main.async {
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
                
                self?.dateSections = self?.groupAssetsByDate(fetchResult) ?? []
                self?.collectionView.reloadData()
            }
        }
    }
    
    private func groupAssetsByDate(_ fetchResult: PHFetchResult<PHAsset>) -> [DateSection] {
        var sections = [DateSection]()
        var currentDateKey: String?
        var currentAssets = [PHAsset]()
        
        let calendar = Calendar.current
        
        for i in 0..<fetchResult.count {
            let asset = fetchResult[i]
            guard let creationDate = asset.creationDate else { continue }
            
            let dateKey = dateKeyForDate(creationDate, calendar: calendar)
            
            if dateKey != currentDateKey {
                if !currentAssets.isEmpty, let key = currentDateKey {
                    if let firstAsset = currentAssets.first, let date = firstAsset.creationDate {
                        sections.append(DateSection(date: date, dateString: key, assets: currentAssets))
                    }
                }
                currentDateKey = dateKey
                currentAssets = [asset]
            } else {
                currentAssets.append(asset)
            }
        }
        
        if !currentAssets.isEmpty, let key = currentDateKey {
            if let firstAsset = currentAssets.first, let date = firstAsset.creationDate {
                sections.append(DateSection(date: date, dateString: key, assets: currentAssets))
            }
        }
        
        return sections
    }
    
    private func dateKeyForDate(_ date: Date, calendar: Calendar) -> String {
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if calendar.isDate(date, inSameDayAs: today) {
            return "今天"
        } else if calendar.isDate(date, inSameDayAs: yesterday) {
            return "昨天"
        } else if calendar.component(.year, from: date) == calendar.component(.year, from: today) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM月dd日"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: date)
        }
    }
    
    deinit {
        cancelAllPrefetchRequests()
//        imageManager.stopCachingImagesForAllAssets()
    }
    
    private func cancelAllPrefetchRequests() {
        for (_, requestID) in prefetchRequests {
            imageManager.cancelImageRequest(requestID)
        }
        prefetchRequests.removeAll()
    }
    
    private func assetForIndexPath(_ indexPath: IndexPath) -> PHAsset? {
        guard indexPath.section < dateSections.count else { return nil }
        let section = dateSections[indexPath.section]
        guard indexPath.item < section.assets.count else { return nil }
        return section.assets[indexPath.item]
    }
}

extension TestPhotoAlbumListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dateSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < dateSections.count else { return 0 }
        return dateSections[section].assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        guard let asset = assetForIndexPath(indexPath) else { return cell }
        
        cell.cancelCurrentRequest()
        cell.expectedIndexPath = indexPath

        let imageManager = imageManager
        let imageSize = imageSize
        
        #if true  // 主线程+渐进式回调(快速滑动效果最佳)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        
        let requestID = imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options) { [weak cell] image, _ in
            DispatchQueue.main.async {
                if let image = image, let cell = cell, !cell.isCancelled, cell.expectedIndexPath == indexPath {
                    cell.imageView.image = image
                    
                    print("image loaded, indexPath: \(indexPath), image size: \(image.size), image scale: \(image.scale)")
                }
            }
        }

        cell.currentRequestID = requestID
        cell.isCancelled = false
        #elseif false // 主线程+模拟渐渐回调(快速滑动效果不佳)
        let quickOptions = PHImageRequestOptions()
        quickOptions.deliveryMode = .opportunistic
        quickOptions.isNetworkAccessAllowed = true
        quickOptions.resizeMode = .fast
        
        let requestID = imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: quickOptions) { [weak cell] image, _ in
            DispatchQueue.main.async {
                if let image = image, let cell = cell, !cell.isCancelled, cell.expectedIndexPath == indexPath {
                    cell.imageView.image = image
                    
                    print("image loaded, indexPath: \(indexPath), image size: \(image.size), image scale: \(image.scale)")
                    
                    let highQualityOptions = PHImageRequestOptions()
                    highQualityOptions.deliveryMode = .highQualityFormat
                    highQualityOptions.isNetworkAccessAllowed = true
                    highQualityOptions.resizeMode = .fast
                    let newRequestID = imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: highQualityOptions) { [weak cell] image, _ in
                        DispatchQueue.main.async {
                            if let image = image, let cell = cell, !cell.isCancelled, cell.expectedIndexPath == indexPath {
                                cell.imageView.image = image
                                
                                print("image loaded, indexPath: \(indexPath), image size: \(image.size), image scale: \(image.scale)")
                                
                                
                            }
                        }
                    }
                    cell.currentRequestID = newRequestID
                }
            }
        }

        cell.currentRequestID = requestID
        cell.isCancelled = false
        #else  // 子线程请求+渐进回调 (快速滑动效果不佳)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        
        highPriorityQueue.async {
            let requestID = imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options) { [weak cell] image, _ in
                DispatchQueue.main.async {
                    if let image = image, let cell = cell, !cell.isCancelled, cell.expectedIndexPath == indexPath {
                        cell.imageView.image = image
                    }
                }
            }
            
            DispatchQueue.main.async {
                cell.currentRequestID = requestID
            }
        }
        
        cell.isCancelled = false
        #endif
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DateHeader", for: indexPath) as! DateHeaderView
        guard indexPath.section < dateSections.count else { return header }
        
        header.titleLabel.text = dateSections[indexPath.section].dateString
        
        return header
    }
}

class DateHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.backgroundColor = .clear
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PhotoCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    var currentRequestID: PHImageRequestID?
    var isCancelled = false
    var expectedIndexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelCurrentRequest() {
        isCancelled = true
        expectedIndexPath = nil
        if let requestID = currentRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
            currentRequestID = nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelCurrentRequest()
        imageView.image = nil
    }
}
