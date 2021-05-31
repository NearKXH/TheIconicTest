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
    
    var baseUrl: String
    var path: String
    var queryItems: [String: String]?
    var method: HTTPMethod = .GET
    
    var url: URL {
        get { urlLink }
        set { urlLink = newValue }
    }
    
    private var urlLink: URL
    
    init?(url: String) {
        guard let urlLink = URL(string: url) else {
            fatalError("init(url:) has not been implemented. Invalid URL: \(url)")
        }
        
        self.urlLink = urlLink
        
        baseUrl = urlLink.baseURL?.absoluteString ?? ""
        path = urlLink.path
        
        queryItems = [:]
        let components = URLComponents(string: url)
        components?.queryItems?.forEach({ (query) in
            if let value = query.value {
                queryItems?[query.name] = value
            }
        })
    }
}
