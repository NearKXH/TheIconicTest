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
    
    private let dataSource = BehaviorRelay<[CatalogProductVMModel]>(value: [])
    private let refresh = BehaviorRelay(value: RefreshEndStatus.normal)
    
    private let networkBehaviorRelay: BehaviorRelay<Single<[ProductModel]>> = {
        let single = Single<[ProductModel]>.create { (single) -> Disposable in
            single(.success([]))
            return Disposables.create {}
        }
        return BehaviorRelay(value: single)
    }()
    
    private let disposeBag = DisposeBag()
    private let network = NetworkManager.manager
    
    required init(input: Input) {
        self.input = input
        self.output = Output(dataSource: dataSource.asDriver(onErrorJustReturn: []), refresh: refresh.asDriver(onErrorJustReturn: .normal))
        
        /// init finished
        networkBehaviorObserve()

        input.refresh.subscribe(onNext: { [unowned self] (refresh) in
            if case .error(_) = self.refresh.value {
                // The request of Header is error
                // send it again
                networkBehaviorObserve()
                if refreshBeginStatus == .header || refreshBeginStatus == refresh {
                    return
                }
            }
            
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
    
    private func networkBehaviorObserve() {
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
            
        }, onError: { [unowned self] (error) in
            print(error)
            switch refreshBeginStatus {
            case .header:
                dataSource.accept([])
                refresh.accept(.error(refreshBeginStatus))
            case .footer:
                refresh.accept(.error(refreshBeginStatus))
            case .none:
                refresh.accept(.normal)
            }

        }).disposed(by: disposeBag)
    }
    
}
