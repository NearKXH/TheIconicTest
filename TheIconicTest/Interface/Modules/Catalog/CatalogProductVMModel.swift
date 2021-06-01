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
    
    lazy var descriptionAttributedText: NSAttributedString? = {
        return try? NSAttributedString(data: short_description.data(using: .utf8) ?? Data(), options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
    }()
    
    init(product: ProductModel) {
        sku = product.sku ?? ""
        final_price = String(format: "%.2f", product.final_sale ?? product.price ?? 0.0)
        price = String(format: "%.2f", product.price ?? 0.0)
        name = product.name ?? ""
        short_description = product.short_description ?? ""
        
        imageUrl = product._embedded?.images?.first?.url ?? ""
        brandName = product._embedded?.brand?.name ?? ""
        
        // Like info should be saved in service and reviced by request
        // Now use UserDefaults to simulate the storage situation
        let like = UserDefaults.standard.bool(forKey: sku)
        if like {
            likeObservable.accept(true)
        }
        
        var initObser = true
        likeObservable.subscribe(onNext: { [unowned self] (like) in
            guard initObser else {
                // do not send request at init value
                initObser = false
                return
            }
            
            UserDefaults.standard.setValue(like, forKey: sku)
            UserDefaults.standard.synchronize()
            
        }).disposed(by: disposeBag)
    }
}
