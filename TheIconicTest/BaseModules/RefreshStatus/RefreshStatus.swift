//
//  RefreshStatus.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

enum RefreshBeginStatus {
    case none
    
    case header
    case footer
}

enum RefreshEndStatus {
    case normal
    case noMoreData
    
    case error(RefreshBeginStatus)
}
