//
//  NetworkService.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

/// Base Network Service, implement the request
///
/// This implement do not depend on any other framework
class NetworkService: Service {
    
    private let session = URLSession.shared
    
    private func sendRequest(_ urlRequest: URLRequest, completion: @escaping (Result<Response, NetworkError>) -> Void) -> ServiceTask {
        let task = session.dataTask(with: urlRequest) { (data, urlResponse, error) in
            if let error = error {
                completion(.failure(.requestFailed(error)))
            } else {
                completion(.success(Response(data: data, urlResponse: urlResponse)))
            }
        }
        task.resume()

        return task
    }
    
    func request<E>(_ request: E, completion: @escaping (Result<E.ResponseType?, NetworkError>) -> Void) -> ServiceTask where E : Request {
        
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        
        if let headers = request.headers {
            headers.forEach { (key, value) in
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }

        return sendRequest(urlRequest) { (result) in
            switch result {
            case let .success(response):
                if let data = response.data, let obj = try? request.decoder.decode(E.ResponseType.self, from: data) {
                    completion(.success(obj))
                } else {
                    completion(.success(nil))
                }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension URLSessionDataTask: ServiceTask {}
