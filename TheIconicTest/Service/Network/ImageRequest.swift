//
//  ImageRequest.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/6/1.
//

import Foundation
import UIKit

struct ImageNetwork: Request {
    
    typealias ResponseType = String
    
    let baseUrl: String
    let path: String
    let queryItems: [String: String]?
    var method: HTTPMethod = .GET
    
    var url: URL {
        get { originalUrl }
    }
    
    private var originalUrl: URL
    
    init?(url: String) {
        guard let urlLink = URL(string: url) else {
            fatalError("init(url:) has not been implemented. Invalid URL: \(url)")
        }
        
        originalUrl = urlLink
        
        baseUrl = urlLink.baseURL?.absoluteString ?? ""
        path = urlLink.path
        
        var queryItems = [String: String]()
        let components = URLComponents(string: url)
        components?.queryItems?.forEach({ (query) in
            if let value = query.value {
                queryItems[query.name] = value
            }
        })
        
        self.queryItems = queryItems
    }
}
