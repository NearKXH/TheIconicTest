//
//  ImageServiceManager.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/6/1.
//

import Foundation
import UIKit

enum ImageCacheType {
    case shared
    case name(String)
}

class ImageCache {
    private let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        return cache
    }()
    
    let cacheType: ImageCacheType
    
    static let shared = ImageCache(cacheType: .shared)
    
    private init(cacheType: ImageCacheType) {
        self.cacheType = cacheType
    }
    
    convenience init(_ name: String) {
        self.init(cacheType: .name(name))
    }
    
    func object(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func setObject(_ obj: UIImage, forKey key: String) {
        cache.setObject(obj, forKey: key as NSString)
    }

    func removeObject(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func removeAllObjects() {
        cache.removeAllObjects()
    }
}

class ImageServiceManager: Download {
    
    private struct ImageServiceTask: ServiceTask {
        let taskIdentifier: Int = 0
        let originalRequest: URLRequest?
        let currentRequest: URLRequest?
        
        func cancel() {}
    }
    
    private lazy var service = { NetworkService() }()
    private lazy var fileManager = { FileManager() }()
    private let cacheDirPath: String = {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return documents + "/imageCaches"
    }()
    
    let cacheType: ImageCacheType
    let cache: ImageCache
    
    static let shared = ImageServiceManager(cacheType: .shared)
    
    private init(cacheType: ImageCacheType) {
        self.cacheType = cacheType
        
        switch cacheType {
        case .shared:
            cache = ImageCache.shared
        case let .name(name):
            cache = ImageCache(name)
        }
    }
    
    convenience init(_ name: String) {
        self.init(cacheType: .name(name))
    }
    
    func downloadImage<E>(_ request: E, completion: @escaping (Result<UIImage?, NetworkError>) -> Void) -> ServiceTask where E : Request {
        let sha = request.url.absoluteString.sha256()
        
        if let image = cache.object(forKey: sha) {
            // Local Cache
            let urlRequest = URLRequest(url: request.url)
            completion(.success(image))
            return ImageServiceTask(originalRequest: urlRequest, currentRequest: urlRequest)
            
        } else {
            // File Cache
            if fileManager.fileExists(atPath: cacheDirPath + "/\(sha)") {
                // load data may be a large task, put it into global queue
                DispatchQueue.global().async { [unowned self] in
                    if let data = fileManager.contents(atPath: cacheDirPath + "/\(sha)"), let image = UIImage(data: data) {
                        completion(.success(image))
                    } else {
                        let _ = sendDownloadRequest(request, completion: completion)
                    }
                }
                
                let urlRequest = URLRequest(url: request.url)
                return ImageServiceTask(originalRequest: urlRequest, currentRequest: urlRequest)
            }
            
            // Request Service
            return sendDownloadRequest(request, completion: completion)
        }
    }
    
    private func sendDownloadRequest<E>(_ request: E, completion: @escaping (Result<UIImage?, NetworkError>) -> Void) -> ServiceTask where E : Request {
        
        return service.downloadImage(request) { [unowned self] (result) in
            switch result {
            case let .success(image):
                if let image = image {
                    let sha = request.url.absoluteString.sha256()
                    cache.setObject(image, forKey: sha)
                    
                    DispatchQueue.global().async { [unowned self] in
                        
                        // The task of write data and change image to data, may be large, put it into global queue
                        if let data = image.pngData() {
                            if !fileManager.fileExists(atPath: cacheDirPath) {
                                try? fileManager.createDirectory(atPath: cacheDirPath, withIntermediateDirectories: true, attributes: nil)
                            }
                            
                            try? data.write(to: URL(fileURLWithPath: cacheDirPath + "/\(sha)"))
                        }
                    }
                }
                completion(.success(image))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
    }
    
}
