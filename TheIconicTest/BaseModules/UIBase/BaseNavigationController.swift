//
//  BaseNavigationController.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import UIKit

import RxSwift

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private let disposeBag = DisposeBag()
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            let image = UIImage(named: "Close_Arrow_Left")?.withRenderingMode(.alwaysOriginal)
            let left = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
            left.rx.tap.asDriver().asObservable().subscribe(onNext: { [unowned self] in
                self.popViewController(animated: true)
            }).disposed(by: disposeBag)
            
            viewController.navigationItem.leftBarButtonItem = left
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
