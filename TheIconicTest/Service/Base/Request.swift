//
//  Request.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

enum HTTPMethod: String {
    case GET = "GET"
}

protocol Request {
    
    associatedtype ResponseType: Codable
    
    var url: URL { get }
    
    var baseUrl: String { get }
    var path: String { get }
    var queryItems: [String: String]? { get }
    var method: HTTPMethod { get }
    var decoder: JSONDecoder { get }
    
    var headers: [String: String]? { get }
}

extension Request {
    
    var url: URL {
        guard let url = URL(string: baseUrl) else {
            preconditionFailure(
                "Invalid Base URL: \(baseUrl)"
            )
        }
        
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.path = path.count > 0 ? "/" + path : ""
        components.queryItems = queryItems?.map({
            URLQueryItem(name: $0, value: $1)
        })

        guard let componentsUrl = components.url else {
            preconditionFailure(
                "Invalid URL components: \(components)"
            )
        }
        
        return componentsUrl
    }
    
    var path: String { "" }
    var queryItems: [String: String]? { nil }
    var method: HTTPMethod { .GET }
    
    var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    var headers: [String: String]? { nil }
    
}
