//
//  LinksModel.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

struct LinksHrefModel: Codable {
    let href: String?
}

struct LinksModel: Codable {
    let `self`: LinksHrefModel?
    let first: LinksHrefModel?
    let last: LinksHrefModel?
    let next: LinksHrefModel?
}
