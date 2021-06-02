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
    
    private var footerBeginRefresh: BehaviorRelay<RefreshBeginStatus>!
    private var footerEndRefresh: BehaviorRelay<RefreshEndStatus>!
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.refreshControl = refreshControl
        
        collectionView.register(CatalogCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        return collectionView
    }()
    
    private lazy var noDataCoverView: UIView = {
        let coverView = UIView(frame: view.bounds)
        coverView.backgroundColor = .white
        
        let label = UILabel()
        label.text = "Error while loading\nTap to retry"
        label.textColor = .textColor
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.sizeToFit()
        coverView.addSubview(label)
        
        var center = coverView.center
        center.y -= 32
        label.center = center
        
        center.y += 32 + 32
        self.noDataCoverActivity.center = center
        coverView.addSubview(self.noDataCoverActivity)
        
        let coverButton = UIButton(type: .custom)
        coverButton.frame = coverView.bounds
        coverButton.rx.controlEvent(.touchUpInside).subscribe(onNext: { [unowned self] in
            self.footerBeginRefresh.accept(.header)
            self.noDataCoverActivity.startAnimating()
        }).disposed(by: disposeBag)
        coverView.addSubview(coverButton)
        
        view.addSubview(coverView)
        
        return coverView
    }()
    
    private lazy var noDataCoverActivity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.isHidden = true
        return activity
    }()
    
    private var vm: CatalogViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "THE ICONIC"
        
        view.addSubview(collectionView)
        
        (footerBeginRefresh, footerEndRefresh) = collectionView.rx.addFooter()
        
        let headerRefresh = refreshControl.rx.controlEvent(.valueChanged).map({ RefreshBeginStatus.header }).startWith(.header)
        let refreshObservable = Observable.of(headerRefresh, footerBeginRefresh.asObservable()).merge().startWith(.header)
        
        vm = CatalogViewModel(input: CatalogViewModel.Input(refresh: refreshObservable))
        
        vm.output.dataSource.asObservable().bind(to: collectionView.rx.items(cellIdentifier: "cell", cellType: CatalogCollectionViewCell.self)) {
            (_, element, cell) in
            cell.bind(element)
        }.disposed(by: disposeBag)
        
        vm.output.refresh.asObservable().subscribe(onNext: { [unowned self] (refresh) in
            refreshControl.endRefreshing()
            footerEndRefresh.accept(refresh)
            
            if case let .error(begin) = refresh, begin == .header {
                showNoDataCoverView()
            } else if collectionView.isHidden {
                collectionView.isHidden = false
                noDataCoverView.isHidden = true
                noDataCoverActivity.stopAnimating()
            }
            
        }).disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(CatalogProductVMModel.self).subscribe(onNext: { [unowned self] (product) in
            navigationController?.pushViewController(ProductDetailViewController(product: product), animated: true)
        }).disposed(by: disposeBag)
        
    }
    
    private func showNoDataCoverView() {
        collectionView.isHidden = true
        noDataCoverView.isHidden = false
        noDataCoverActivity.isHidden = true
        noDataCoverActivity.stopAnimating()
    }
}
