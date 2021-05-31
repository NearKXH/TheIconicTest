//
//  CatalogNetwork.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

import RxSwift

struct CatalogNetwork: Request {
    
    typealias ResponseType = CatalogModel
    
    static let pageSize = 30
    
    let path: String = "v1/catalog/products"
    
    let queryItems: [String : String]?
    
    init(page: Int) {
        queryItems = ["page_size": "\(CatalogNetwork.pageSize)", "page": "\(min(page, 1))"]
    }
}

extension Reactive where Base: NetworkInterface {
    func catalog(page: Int) -> Single<[ProductModel]> {
        return request(CatalogNetwork(page: page)).map { (result) in
            let product = result?._embedded?.product ?? []
            return product
        }
    }
}
