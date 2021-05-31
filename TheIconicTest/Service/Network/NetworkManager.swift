//
//  NetworkManager.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

import RxSwift

extension Request {
    var baseUrl: String { "https://eve.theiconic.com.au" }
}

/// Network Interface Protocol for application
protocol NetworkInterface: Service {}

/// Network Manager for application
class NetworkManager: NSObject, NetworkInterface {
    private let service = NetworkService()
    
    func request<E>(_ request: E, completion: @escaping (Result<E.ResponseType?, NetworkError>) -> Void) -> ServiceTask where E : Request {
        return service.request(request, completion: completion)
    }
    
    func downloadImage<E>(_ request: E, completion: @escaping (Result<UIImage?, NetworkError>) -> Void) -> ServiceTask where E : Request {
        return service.downloadImage(request, completion: completion)
    }
    
    /// create a new Network Manager, not singleton
    ///
    /// The entry of NetworkManager, that make it easy to change to singleton
    static var manager: NetworkManager {
        return NetworkManager()
    }
    
    private override init() { super.init() }
}

extension Reactive where Base: NetworkInterface {
    /// Rx Request
    /// - Parameter request: Request
    /// - Returns: Single<E.ResponseType?>
    func request<E: Request>(_ request: E) -> Single<E.ResponseType?> {
        return Single.create { single in
            let token = base.request(request) { (result) in
                switch result {
                case let .success(response):
                    single(.success(response))
                case let .failure(error):
                    single(.failure(error))
                }
            }

            return Disposables.create {
                token.cancel()
            }
        }
    }
    
    /// Rx Download Image
    /// - Parameter request: Request
    /// - Returns: Single<UIImage?>
    func downloadImage<E: Request>(_ request: E) -> Single<UIImage?> {
        return Single.create { single in
            let token = base.downloadImage(request) { (result) in
                switch result {
                case let .success(response):
                    single(.success(response))
                case let .failure(error):
                    single(.failure(error))
                }
            }

            return Disposables.create {
                token.cancel()
            }
        }
    }
}
