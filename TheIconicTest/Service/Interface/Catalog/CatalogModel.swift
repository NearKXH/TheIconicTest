//
//  CatalogModel.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

struct CatalogEmbeddedModel: Codable {
    let product: Array<ProductModel>?
}

struct CatalogModel: Codable {
    let _embedded: CatalogEmbeddedModel?
    
    let page_count: Int?
    let page_size: Int?
    let total_items: Int?
    let page: Int?
    
    let _link: LinksModel?
}
