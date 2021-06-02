//
//  CatalogViewController.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import UIKit

import RxCocoa
import RxSwift

class CatalogViewController: BaseViewController {
    
    private let collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.size.width - 16 * 2 - 16) / 2.0
        let height = width * 1.25 + 49
        layout.itemSize = CGSize(width: width, height: height)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return layout
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
        return refreshControl
    }()
    
    private var footerEndRefresh: BehaviorRelay<RefreshEndStatus>!
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.refreshControl = refreshControl
        
        collectionView.register(CatalogCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        return collectionView
    }()
    
    private var vm: CatalogViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "THE ICONIC"
        
        view.addSubview(collectionView)
        
        let (footerBegin, footerEnd) = collectionView.rx.addFooter()
        footerEndRefresh = footerEnd
        
        let headerRefresh = refreshControl.rx.controlEvent(.valueChanged).map({ RefreshBeginStatus.header }).startWith(.header)
        let refreshObservable = Observable.of(headerRefresh, footerBegin.asObservable()).merge().startWith(.header)
        
        vm = CatalogViewModel(input: CatalogViewModel.Input(refresh: refreshObservable))
        
        vm.output.dataSource.asObservable().bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: CatalogCollectionViewCell.self)) {
            (_, element, cell) in
            cell.bind(element)
        }.disposed(by: disposeBag)
        
        vm.output.refresh.asObservable().subscribe(onNext: { [unowned self] (refresh) in
            footerEndRefresh.accept(refresh == .none ? .normal : refresh)
            refreshControl.endRefreshing()
        }).disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(CatalogProductVMModel.self).subscribe(onNext: { [unowned self] (product) in
            navigationController?.pushViewController(ProductDetailViewController(product: product), animated: true)
        }).disposed(by: disposeBag)
        
    }
}
