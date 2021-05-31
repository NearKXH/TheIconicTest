//
//  ProductVMModel.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation
import UIKit

class CatalogProductVMModel {
    let sku: String
    let final_price: String
    let price: String
    let name: String
    let short_description: String
    let imageUrl: String
    let brandName: String
    
    var images: UIImage? = nil
    
    init(product: ProductModel) {
        sku = product.sku ?? ""
        final_price = String(format: "%.2f", product.final_sale ?? 0.0)
        price = String(format: "%.2f", product.price ?? 0.0)
        name = product.name ?? ""
        short_description = product.short_description ?? ""
        
        imageUrl = product._embedded?.images?.first?.url ?? ""
        brandName = product._embedded?.brand?.name ?? ""
    }
}
