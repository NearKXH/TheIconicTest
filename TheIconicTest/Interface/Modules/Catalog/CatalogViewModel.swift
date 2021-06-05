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
        let dataSource = BehaviorRelay<[CatalogProductVMModel]>(value: [])
        let refreshEndStatus = BehaviorRelay(value: RefreshEndStatus.normal)
        
        self.input = input
        self.output = Output(dataSource: dataSource.asDriver(onErrorJustReturn: []), refresh: refreshEndStatus.asDriver(onErrorJustReturn: .normal))
        
        let networkBehaviorRelay: BehaviorRelay<Single<[ProductModel]>> = {
            let single = Single<[ProductModel]>.create { (single) -> Disposable in
                single(.success([]))
                return Disposables.create {}
            }
            return BehaviorRelay(value: single)
        }()
        
        /// init finished
        networkBehaviorRelay.flatMapLatest({ (single) in
            return single.map { (products) in
                Result<[ProductModel], Error>.success(products)
            }.asInfallible { (error) -> Infallible<Result<[ProductModel], Error>> in
                Infallible.create { (infallible) -> Disposable in
                    infallible(InfallibleEvent.next(Result.failure(error)))
                    return Disposables.create {}
                }
            }
        }).map { (result) -> Result<[CatalogProductVMModel], Error> in
            switch result {
            case let .success(products):
                return .success(products.map({ (product) in
                    CatalogProductVMModel(product: product)
                }))
            case let .failure(error):
                return .failure(error)
            }
        }.subscribe(onNext: { [unowned self] (result) in
            switch result {
            case let .success(products):
                switch refreshBeginStatus {
                case .header:
                    dataSource.accept(products)
                case .footer:
                    dataSource.accept(dataSource.value + products)
                case .none:
                    refreshEndStatus.accept(.normal)
                    return
                }

                page = page + 1
                refreshBeginStatus = .none
                refreshEndStatus.accept( products.count < CatalogNetwork.pageSize ? .noMoreData : .normal)
                
            case let .failure(error):
                print(error)
                switch refreshBeginStatus {
                case .header:
                    dataSource.accept([])
                    refreshEndStatus.accept(.error(refreshBeginStatus))
                case .footer:
                    refreshEndStatus.accept(.error(refreshBeginStatus))
                case .none:
                    refreshEndStatus.accept(.normal)
                }
                
                refreshBeginStatus = .none
            }

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
