//
//  CatalogViewModelTest.swift
//  TheIconicTestTests
//
//  Created by Near Kong on 2021/6/2.
//

import XCTest
@testable import TheIconicTest

import RxTest
import RxCocoa
import RxSwift

class CatalogViewModelTest: XCTestCase {
    
    let disposeBag = DisposeBag()
    
    func testData() {
        
        let beginRefresh = BehaviorRelay(value: RefreshBeginStatus.none)
        
        let catalogVM = CatalogViewModel(input: CatalogViewModel.Input(refresh: beginRefresh.asObservable()))
        
        var dataSourceTimes = 0
        var dataSourceEnd = false
        var dataSourceResults = [Int]()
        catalogVM.output.dataSource.asObservable().subscribe(onNext: { (productModel) in
            dataSourceResults.append(productModel.count)
            dataSourceTimes += 1
            if dataSourceTimes == 3 {
                dataSourceEnd = true
            }
        }).disposed(by: disposeBag)
        
        var refreshTimes = 0
        var refreshEnd = false
        var refreshResults = [RefreshEndStatus]()
        catalogVM.output.refresh.asObservable().subscribe(onNext: { (refreshStatus) in
            refreshResults.append(refreshStatus)
            refreshTimes += 1
            if refreshTimes == 3 {
                refreshEnd = true
            }
        }).disposed(by: disposeBag)
        
        beginRefresh.accept(.header)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2) {
            beginRefresh.accept(.footer)
        }
        
        while !(dataSourceEnd && refreshEnd) {
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 4))
        }
        
        XCTAssertEqual(refreshResults, [.normal, .normal, .normal])
        XCTAssertEqual(dataSourceResults, [0, 30, 60])
    }
}
