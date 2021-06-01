//
//  ProductDetailViewController.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import UIKit

import RxSwift
import RxCocoa

class ProductDetailViewController: BaseViewController, UITableViewDelegate {
    
    private enum TableViewRow: Int {
        case image          = 0
        case info           = 1
        case bag            = 2
        case description    = 3
    }
    
    private let product: CatalogProductVMModel
    private let disposeBag = DisposeBag()
    
    private lazy var dataSource: Observable<[CatalogProductVMModel]> = {
        Observable.of(Array(repeating: product, count: 4))
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        tableView.register(ProductDetailImageTableViewCell.self, forCellReuseIdentifier: "image")
        tableView.register(ProductDetailInfoTableViewCell.self, forCellReuseIdentifier: "info")
        tableView.register(ProductDetailBagTableViewCell.self, forCellReuseIdentifier: "bag")
        tableView.register(ProductDetailDescriptionTableViewCell.self, forCellReuseIdentifier: "description")
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "default")
        
        return tableView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(product: CatalogProductVMModel) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = product.brandName
        
        view.addSubview(tableView)

        dataSource.bind(to: tableView.rx.items) { (tableView, row, element) -> UITableViewCell in
            let indexPath = IndexPath(row: row, section: 0)
            var cellIdentifier = "default"
            
            if let rowEnum = TableViewRow(rawValue: row) {
                switch rowEnum {
                case .image:
                    cellIdentifier = "image"
                case .bag:
                    cellIdentifier = "bag"
                case .info:
                    cellIdentifier = "info"
                case .description:
                    cellIdentifier = "description"
                }
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            if let cell = cell as? ProductDetailTableViewCell {
                cell.bind(element)
            }
            
            return cell
        }.disposed(by: disposeBag)
    }
}
