//
//  CatalogViewModel.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

import RxSwift
import RxCocoa

struct CatalogViewModel: ViewModelProtocol {
    
    struct Input {
        
    }
    
    struct Output {
//        let dataSource: Driver<[CatalogProductVMModel]>
    }
    
    let input: Input
    let output: Output
    
    private let models = BehaviorRelay<[ProductModel]>(value: [])
    private var page: Int = 1
    
    private let disposeBag = DisposeBag()
    
    init(input: Input) {
        self.input = input
        self.output = Output()
    }
    
}
