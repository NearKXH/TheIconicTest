//
//  RefreshStatus.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import Foundation

enum RefreshBeginStatus {
    case none
    
    case beingHeaderRefresh
    case beingFooterRefresh
}

enum RefreshEndStatus {
    case none
    
    case endRefresh
    case endRefreshWithNoMoreData
}
