//
//  Service.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation
import UIKit

enum NetworkError: Error {
    case requestFailed(Error?)
}

protocol ServiceTask {
    var taskIdentifier: Int { get }
    
    var originalRequest: URLRequest? { get }

    var currentRequest: URLRequest? { get }
    
    func cancel()
    
}

protocol Service {
    @discardableResult
    func request<E: Request>(_ request: E, completion: @escaping (Result<E.ResponseType?, NetworkError>) -> Void) -> ServiceTask
}

protocol Download {
    @discardableResult
    func downloadImage<E: Request>(_ request: E, completion: @escaping (Result<UIImage?, NetworkError>) -> Void) -> ServiceTask
}
