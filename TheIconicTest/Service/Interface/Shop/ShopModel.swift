//
//  ShopModel.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

struct ShopModel: Codable {
    let is_default: Bool?
    let name: String?
    
    let _links: LinksModel?
}

