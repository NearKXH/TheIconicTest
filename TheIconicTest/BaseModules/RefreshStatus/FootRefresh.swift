//
//  FootRefresh.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/6/1.
//

import Foundation
import UIKit

import RxCocoa
import RxSwift

class FooterRefresher: UIView {
    
    static var associatedKey: String = "FooterRefresher_AssociatedKey"
    
    private weak var scrollView: UIScrollView!
    
    private lazy var readyRefreshView: UIView = {
        let view = UIView(frame: bounds)
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9)
        label.text = "- PULL UP FOR MORE -"
        label.textColor = .textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        return view
    }()
    
    private lazy var activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.translatesAutoresizingMaskIntoConstraints = false
        return activity
    }()
    
    private lazy var refreshingView: UIView = {
        let view = UIView(frame: bounds)
        view.isHidden = true
        
        view.addSubview(activity)
        
        activity.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activity.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        return view
    }()
    
    private lazy var noMoreDataView: UIView = {
        let view = UIView(frame: bounds)
        view.isHidden = true
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9)
        label.text = "- No More Data -"
        label.textColor = .textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        return view
    }()
    
    private lazy var footerView: UIView = {
        let footer = UIView(frame: bounds)
        
        footer.addSubview(readyRefreshView)
        footer.addSubview(refreshingView)
        footer.addSubview(noMoreDataView)
        
        return footer
    }()
    
    private enum FooterRefreshStatus {
        case normal
        case refreshing
        case noMoreData
    }
    
    private var refreshStatus: FooterRefreshStatus = .normal
    let begin = BehaviorRelay<RefreshBeginStatus>(value: .none)
    let end = BehaviorRelay<RefreshEndStatus>(value: .none)
    
    private let disposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ scrollView: UIScrollView) {
        super.init(frame: CGRect(x: scrollView.contentInset.left, y: scrollView.contentSize.height, width: scrollView.frame.width, height: 44))
        
        self.scrollView = scrollView
        
        confirmUI()
        confirmObservable()
    }
    
    private func confirmUI() {
        addSubview(footerView)
    }
    
    private func confirmObservable() {
        scrollView.rx.observe(CGSize.self, "contentSize").asObservable().subscribe(onNext: { [unowned self] (size) in
            if let size = size, size.height != self.frame.origin.y {
                var frame = self.frame
                frame.origin.y = size.height
                self.frame = frame
            }
        }).disposed(by: disposeBag)
        
        scrollView.panGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] (pan) in
            if pan.state == .ended && refreshStatus != .refreshing {
                // just observe the end of pan
                // and refresh view is not refreshing
                if scrollView.contentInset.top + scrollView.contentSize.height < scrollView.frame.height {
                    // less than on screen
                    if scrollView.contentOffset.y > -scrollView.contentInset.top {
                        begin.accept(.footer)
                    }
                } else {
                    if scrollView.contentOffset.y > scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.height {
                        begin.accept(.footer)
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        begin.asDriver(onErrorJustReturn: .none).asObservable().subscribe(onNext: { [unowned self] (refresh) in
            if refresh == .footer {
                beginRefresh()
            }
        }).disposed(by: disposeBag)
        
        end.asDriver(onErrorJustReturn: .none).asObservable().subscribe(onNext: { [unowned self] (refresh) in
            if refresh != .none {
                endRefresh(noMoreData: refresh == .noMoreData)
            }
        }).disposed(by: disposeBag)
    }
    
    private func beginRefresh() {
        guard refreshStatus != .refreshing else {
            return
        }
        
        refreshStatus = .refreshing
        
        activity.startAnimating()
        refreshingView.isHidden = false
        
        readyRefreshView.isHidden = true
        noMoreDataView.isHidden = true
    }
    
    private func endRefresh(noMoreData: Bool) {
        refreshStatus = noMoreData ? .noMoreData : .normal
        
        activity.stopAnimating()
        refreshingView.isHidden = true
        
        readyRefreshView.isHidden = noMoreData
        noMoreDataView.isHidden = !noMoreData
    }
}

extension Reactive where Base: UIScrollView {
    func addFooter() -> (begin: BehaviorRelay<RefreshBeginStatus>, end: BehaviorRelay<RefreshEndStatus>) {
        let footer = FooterRefresher(base)
        base.addSubview(footer)
        base.contentInset.bottom += footer.frame.height
        
        objc_setAssociatedObject(base, &FooterRefresher.associatedKey, footer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return (footer.begin, footer.end)
    }
    
    func removeFooter() {
        let footer = objc_getAssociatedObject(base, &FooterRefresher.associatedKey) as? FooterRefresher
        footer?.removeFromSuperview()
        objc_setAssociatedObject(base, &FooterRefresher.associatedKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
