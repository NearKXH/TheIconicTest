//
//  ProductDetailViewController.swift
//  TheIconicTest
//
//  Created by Near Kong on 2021/5/31.
//

import UIKit

class ProductDetailViewController: BaseViewController {
    
    let product: CatalogProductVMModel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(product: CatalogProductVMModel) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
