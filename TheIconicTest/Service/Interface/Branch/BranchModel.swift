//
//  BranchModel.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

struct BranchModel: Codable {
    let id: Int?
    let name: String?
    let url_key: String?
    let image_url: String?
//    let banner_url: String?
    
    let _links: LinksModel?
}
