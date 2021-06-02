//
//  CatalogCollectionViewCell.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import UIKit

import RxSwift
import RxCocoa

class CatalogCollectionViewCell: BaseCollectionViewCell {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let likeImageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let branchLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = .textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let discountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .discountColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(likeImageView)
        contentView.addSubview(branchLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(discountLabel)
        
        // autolayout
        let vflView = ["imageView": imageView, "branchLabel": branchLabel, "nameLabel": nameLabel, "priceLabel": priceLabel, "discountLabel": discountLabel, "likeImageView": likeImageView]
        
        let vVfl = "V:|-0-[imageView]-4-[branchLabel]-0-[nameLabel]-0-[priceLabel]"
        let vConsts = NSLayoutConstraint.constraints(withVisualFormat: vVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(vConsts)
        
        let hVfl = "H:|-0-[imageView]-0-|"
        let hConsts = NSLayoutConstraint.constraints(withVisualFormat: hVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hConsts)
        
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.25).isActive = true
        
        let vLikeVfl = "V:[imageView]-10-[likeImageView(16)]"
        let vLikeConsts = NSLayoutConstraint.constraints(withVisualFormat: vLikeVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(vLikeConsts)
        
        let hLikeVfl = "H:|-0-[branchLabel]-4-[likeImageView(16)]-0-|"
        let hLikeConsts = NSLayoutConstraint.constraints(withVisualFormat: hLikeVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hLikeConsts)
        
        let hNameVfl = "H:|-0-[nameLabel]-4-[likeImageView(16)]"
        let hNameConsts = NSLayoutConstraint.constraints(withVisualFormat: hNameVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hNameConsts)
        
        let hPriceVfl = "H:|-0-[priceLabel]-2-[discountLabel]"
        let hPriceConsts = NSLayoutConstraint.constraints(withVisualFormat: hPriceVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hPriceConsts)
        
        discountLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor).isActive = true
        discountLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: 0).isActive = true
        priceLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var disposeBag: DisposeBag!
    private var sku: String?
    
    func bind(_ productModel: CatalogProductVMModel) {
        
        guard sku?.count ?? 0 == 0 || productModel.sku != sku! else {
            return
        }

        disposeBag = DisposeBag()
        sku = productModel.sku
        
        branchLabel.text = productModel.brandName
        nameLabel.text = productModel.name
        
        discountLabel.text = "$\(productModel.final_price)"
        discountLabel.isHidden = (productModel.price == productModel.final_price || Float(productModel.final_price) ?? 0.0 == 0)
        
        priceLabel.attributedText = NSAttributedString(string: "$\(productModel.price)", attributes: discountLabel.isHidden ? nil : [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.strikethroughColor: priceLabel.textColor as Any])
        
        productModel.imageObservable.asObservable().subscribe(onNext: { [unowned self] (image) in
            imageView.image = image
        }).disposed(by: disposeBag)
        
        productModel.likeObservable.asDriver().asObservable().subscribe(onNext: { [unowned self] (like) in
            likeImageView.image = like ? UIImage(named: "Wishlist_Active") : UIImage(named: "Wishlist_Default")
        }).disposed(by: disposeBag)

    }
    
}
