//
//  ProductDetailTableViewCell.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/6/1.
//

import UIKit

import RxCocoa
import RxSwift

class ProductDetailTableViewCell: BaseTableViewCell {
    fileprivate var disposeBag: DisposeBag = DisposeBag()
    fileprivate var sku: String?
    
    func bind(_ product: CatalogProductVMModel) {
        guard sku?.count ?? 0 == 0 || product.sku != sku! else {
            return
        }
        
        disposeBag = DisposeBag()
        sku = product.sku
    }
}

class ProductDetailImageTableViewCell: ProductDetailTableViewCell {
    private let productImageView = UIImageView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        productImageView.backgroundColor = .white
        
        contentView.backgroundColor = .backgroundColor
        contentView.addSubview(productImageView)
        
        // autolayout
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        let vflView = ["imageView": productImageView]
        
        let vVfl = "V:|-0-[imageView]-2-|"
        let vConsts = NSLayoutConstraint.constraints(withVisualFormat: vVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(vConsts)
        
        let hVfl = "H:|-0-[imageView]-0-|"
        let hConsts = NSLayoutConstraint.constraints(withVisualFormat: hVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hConsts)
        
        productImageView.heightAnchor.constraint(equalTo: productImageView.widthAnchor, multiplier: 1.25).isActive = true
    }
    
    override func bind(_ product: CatalogProductVMModel) {
        super.bind(product)
        
        product.imageObservable.asObservable().subscribe(onNext: { [unowned self] (image) in
            productImageView.image = image
        }).disposed(by: disposeBag)
    }

}

class ProductDetailInfoTableViewCell: ProductDetailTableViewCell {

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .priceColor
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
    
    private let likeButton: UIButton = {
        let likeButton = UIButton(type: .custom)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        return likeButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(discountLabel)
        contentView.addSubview(likeButton)
        
        // autolayout
        let vflView = ["nameLabel": nameLabel, "priceLabel": priceLabel, "discountLabel": discountLabel, "likeButton": likeButton]
        
        let vVfl = "V:|-16-[nameLabel]-5-[priceLabel]-0-|"
        let vConsts = NSLayoutConstraint.constraints(withVisualFormat: vVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(vConsts)
        
        let hVfl = "H:|-16-[nameLabel]-4-[likeButton(16)]-16-|"
        let hConsts = NSLayoutConstraint.constraints(withVisualFormat: hVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hConsts)
        
        let vLikeVfl = "V:|-16-[likeButton(16)]"
        let vLikeConsts = NSLayoutConstraint.constraints(withVisualFormat: vLikeVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(vLikeConsts)
        
        let hPriceVfl = "H:|-16-[priceLabel]-2-[discountLabel]-4-[likeButton]"
        let hPriceConsts = NSLayoutConstraint.constraints(withVisualFormat: hPriceVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hPriceConsts)
        
        discountLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor).isActive = true
        priceLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        priceLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
    }
    
    override func bind(_ product: CatalogProductVMModel) {
        super.bind(product)
        
        nameLabel.text = product.name
        
        discountLabel.text = "$\(product.final_price)"
        discountLabel.isHidden = (product.price == product.final_price || Float(product.final_price) ?? 0.0 == 0)
        
        priceLabel.attributedText = NSAttributedString(string: "$\(product.price)", attributes: discountLabel.isHidden ? nil : [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.strikethroughColor: priceLabel.textColor as Any])
        
        product.likeObservable.subscribe(onNext: { [unowned self] (like) in
            likeButton.setImage(like ? UIImage(named: "Wishlist_Active") : UIImage(named: "Wishlist_Default"), for: .normal)
        }).disposed(by: disposeBag)
        
        likeButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {
            let like = product.likeObservable.value
            product.likeObservable.accept(!like)
        }).disposed(by: disposeBag)
    }

}

class ProductDetailBagTableViewCell: ProductDetailTableViewCell {

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let addButton: UIButton = {
        let addButton = UIButton(type: .custom)
        addButton.layer.cornerRadius = 4
        addButton.layer.masksToBounds = true
        addButton.backgroundColor = .blueColor
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        addButton.setTitle("ADD TO BAG", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        return addButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(addButton)
        
        // autolayout
        let vflView = ["addButton": addButton]
        
        let vVfl = "V:|-16-[addButton]-16-|"
        let vConsts = NSLayoutConstraint.constraints(withVisualFormat: vVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(vConsts)
        
        let hVfl = "H:|-16-[addButton]-16-|"
        let hConsts = NSLayoutConstraint.constraints(withVisualFormat: hVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hConsts)
        
    }
    
    override func bind(_ product: CatalogProductVMModel) {
        super.bind(product)
        
        addButton.rx.controlEvent(.touchUpInside).subscribe(onNext: {
            // Call the bag manager, and post request to service...
            print("Add to bag!")
        }).disposed(by: disposeBag)
    }

}

class ProductDetailDescriptionTableViewCell: ProductDetailTableViewCell {

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .textColor
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .textColor
        label.text = "DETAILS, SIZE & FIT"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let skuLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(lineView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(skuLabel)
        
        // autolayout
        let vflView = ["lineView": lineView, "titleLabel": titleLabel, "descriptionLabel": descriptionLabel, "skuLabel": skuLabel]
        
        let vVfl = "V:|-0-[lineView(0.5)]-24-[titleLabel]-24-[descriptionLabel]-16-[skuLabel]-16-|"
        let vConsts = NSLayoutConstraint.constraints(withVisualFormat: vVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(vConsts)
        
        let hVfl = "H:|-16-[lineView]-16-|"
        let hConsts = NSLayoutConstraint.constraints(withVisualFormat: hVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hConsts)
        
        let hTitleVfl = "H:|-16-[titleLabel]-16-|"
        let hTitleConsts = NSLayoutConstraint.constraints(withVisualFormat: hTitleVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hTitleConsts)
        
        let hDescriptionVfl = "H:|-16-[descriptionLabel]-16-|"
        let hDescriptionConsts = NSLayoutConstraint.constraints(withVisualFormat: hDescriptionVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hDescriptionConsts)
        
        let hSkuVfl = "H:|-16-[skuLabel]-16-|"
        let hSkuConsts = NSLayoutConstraint.constraints(withVisualFormat: hSkuVfl, options: [], metrics: nil, views: vflView)
        contentView.addConstraints(hSkuConsts)
    }
    
    override func bind(_ product: CatalogProductVMModel) {
        super.bind(product)
        descriptionLabel.attributedText = product.descriptionAttributedText
        skuLabel.text = "SKU: \(product.sku)"
    }

}
