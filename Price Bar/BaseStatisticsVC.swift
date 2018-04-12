//
//  BaseStatisticsVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/11/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

class BaseStatisticsVC: UIViewController {
    lazy var indicator: CircleIndicator = {
        let size: CGFloat = 150
        let rect = CGRect(x: self.view.center.x - size / 2,
                          y: self.view.center.y - size,
                          width: size,
                          height: size)
        
        let ind = CircleIndicator(frame: rect)
        ind.backgroundColor = .clear
        ind.decorate(titleColor: .white, colors: (.clear, .red), lineWidth: 10)
        
        return ind
    }()
    var productsCount: Int = 0
    
    lazy var button: GoodButton = {
        let size: CGFloat = 80
        let bottomMargin: CGFloat = 36
        let rect = CGRect(x: view.center.x - size / 2,
                      y: view.frame.height - size - bottomMargin,
                      width: size,
                      height: size)
        
        let btn = GoodButton(frame: rect)
        btn.backgroundColor = .red
        btn.setTitle(R.string.localizable.common_lets_get_start(), for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = R.string.localizable.base_statistics_products_in_base_today()
        label.sizeToFit()
        label.center = view.center
        label.frame.origin.y -= 166
        label.textColor = .white
        
        return label
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(productsCount: Int) {
        self.init()
        
        self.productsCount = productsCount
        self.configurePopup()
        self.modalPresentationStyle = .overCurrentContext
    }
    
    func configurePopup() {
        view.addSubview(titleLabel)
        view.addSubview(indicator)
        view.addSubview(button)
    }
    
    @objc
    func close() {
        self.view.antiObscure {
            self.dismiss(animated: true)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.obscure()
        indicator.startShow(for: (Double(productsCount), Double(productsCount)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    
    
}
