//
//  ProductModel.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

struct ProductReturnPolicyMessageModel: Codable {
    let message: String?
    let bold_substring: String?
}

struct ProductMessagingMarketingModel: Codable {
    let type: String?
    let short: String?
    let medium: String?
    let long: String?
    let color: String?
//    let url: String?
}

struct ProductMessagingModel: Codable {
    let marketing: Array<ProductMessagingMarketingModel>?
//    let operational: Array<Codable>?
}

struct ProductRelatedModel: Codable {
    let count: Int?
    let label: String?
    let visible: Bool?
    let message: String?
}

struct ProductEmbeddedModel: Codable {
    let brand: BranchModel?
    let gender: GenderModel?
    let shops: Array<ShopModel>?
    let images: Array<ProductEmbeddedImageModel>?
}

struct ProductEmbeddedImageModel: Codable {
    let url: String?
    let thumbnail: String?
}

struct ProductModel: Codable {
    
    let video_count: Int?
    let price: Double?
    let markdown_price: Double?
    let special_price: Int?
    let returnable: Bool?
    let final_sale: Bool?
//    let stock_update: Bool?
    let final_price: Double?
    
    let sku: String?
    let name: String?
    let ribbon: String?
    
    let color_name_brand: String?
    
    let short_description: String?
    
    let shipment_type: String?
    let color_name: String?
    let color_hex: String?
//    let cart_price_rules: String?
//    let attributes: String?
//    let simples: String?
//    let sustainability: String?
    let link: String?
    let activated_at: String?
    
    let categories_translated: String?
//    let category_path: String?
//    let category_ids: String?
//    let related_products: String?
//    let image_products: String?
    let attribute_set_identifier: String?
    let supplier: String?
//    let wannaby_id: String?
//    let citrus_ad_id: String?
    
    let associated_skus: String?
    let size_guide_url: String?
    
//    let campaign_details: String?
    
    let return_policy_message: ProductReturnPolicyMessageModel?
    let messaging: ProductMessagingModel?
    let related: ProductRelatedModel?
    let variants: ProductRelatedModel?
    let _embedded: ProductEmbeddedModel?
    
    let _link: LinksModel?
    
}
