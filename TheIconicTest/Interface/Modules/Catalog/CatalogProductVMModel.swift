//
//  ProductVMModel.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation
import UIKit

import RxCocoa
import RxSwift

class CatalogProductVMModel {
    let sku: String
    let final_price: String
    let price: String
    let name: String
    let short_description: String
    let imageUrl: String
    let brandName: String
    
    var imageObservable: Driver<UIImage?> {
        if imageBehavior.value == nil {
            downloadImage()
        }
        return imageBehavior.asDriver()
    }
    
    private lazy var imageBehavior: BehaviorRelay<UIImage?> = {
        BehaviorRelay<UIImage?>(value: nil)
    }()
    
    private let disposeBag = DisposeBag()
    
    private func downloadImage() {
        if let imageRequest = ImageNetwork(url: imageUrl) {
            NetworkManager.manager.rx.downloadImage(imageRequest).subscribe { [unowned self] (result) in
                if case let .success(image) = result {
                    imageBehavior.accept(image)
                }
            }.disposed(by: disposeBag)
        }
    }
    
    let likeObservable = BehaviorRelay(value: false)
    
    init(product: ProductModel) {
        sku = product.sku ?? ""
        final_price = String(format: "%.2f", product.final_sale ?? product.price ?? 0.0)
        price = String(format: "%.2f", product.price ?? 0.0)
        name = product.name ?? ""
        short_description = product.short_description ?? ""
        
        imageUrl = product._embedded?.images?.first?.url ?? ""
        brandName = product._embedded?.brand?.name ?? ""
    }
}
