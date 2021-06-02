//
//  CatalogViewModel.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

import RxSwift
import RxCocoa

class CatalogViewModel: ViewModelProtocol {
    
    struct Input {
        let refresh: Observable<RefreshBeginStatus>
    }
    
    struct Output {
        let dataSource: Driver<[CatalogProductVMModel]>
        let refresh: Driver<RefreshEndStatus>
    }
    
    let input: Input
    let output: Output
    
    private var page: Int = 0
    private var refreshBeginStatus = RefreshBeginStatus.none
    
    private let disposeBag = DisposeBag()
    private let network = NetworkManager.manager
    
    required init(input: Input) {
        self.input = input
        
        let dataSource = BehaviorRelay<[CatalogProductVMModel]>(value: [])
        let refresh = BehaviorRelay(value: RefreshEndStatus.none)
        
        self.output = Output(dataSource: dataSource.asDriver(onErrorJustReturn: []), refresh: refresh.asDriver(onErrorJustReturn: .normal))
        
        /// init finished
        let single = Single<[ProductModel]>.create { (single) -> Disposable in
            single(.success([]))
            return Disposables.create {}
        }
        let networkBehaviorRelay = BehaviorRelay(value: single)
        
        networkBehaviorRelay.flatMapLatest({ $0 }).map({ (products) in
            products.map { (product) in
                CatalogProductVMModel(product: product)
            }
        }).subscribe(onNext: { [unowned self] (products) in
            switch refreshBeginStatus {
            case .header:
                dataSource.accept(products)
            case .footer:
                dataSource.accept(dataSource.value + products)
            case .none:
                refresh.accept(.normal)
                return
            }
            
            page = page + 1
            refreshBeginStatus = .none
            refresh.accept( products.count < CatalogNetwork.pageSize ? .noMoreData : .normal)
            
        }).disposed(by: disposeBag)

        input.refresh.subscribe(onNext: { [unowned self] (refresh) in
            switch refresh {
            case .header:
                page = 0
                refreshBeginStatus = .header
                networkBehaviorRelay.accept(network.rx.catalog(page: self.page + 1))
            case .footer:
                if refreshBeginStatus == .none {
                    refreshBeginStatus = .footer
                    networkBehaviorRelay.accept(self.network.rx.catalog(page: self.page + 1))
                }
            case .none:
                break
            }
        }).disposed(by: disposeBag)
    }
    
}
