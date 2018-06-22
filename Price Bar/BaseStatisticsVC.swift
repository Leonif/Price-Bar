//
//  BaseStatisticsVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/11/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


protocol BaseStatisticsView: class {
    func renderStatistic(goodQuantity: Int)
}


class BaseStatisticsVC: UIViewController, BaseStatisticsView {
    lazy var indicator: CircleIndicator = {
        let size: CGFloat = 150
        let rect = CGRect(x: self.view.center.x - size / 2,
                          y: self.view.center.y - size,
                          width: size,
                          height: size)
        
        let ind = CircleIndicator(frame: rect)
        ind.backgroundColor = .clear
        ind.decorate(titleColor: .white, colors: (.clear, Color.petiteOrchid), lineWidth: 10)
        
        return ind
    }()
    
    lazy var button: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = Color.petiteOrchid
        btn.setTitle(R.string.localizable.common_lets_get_start(), for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        
        return btn
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = R.string.localizable.base_statistics_products_in_base_today()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        
        return label
    }()
    
    var presenter: BaseStatisticsPresenter!

    
    private func configurePopup() {
        
        PriceBarStyles.grayBorderedRounded.apply(to: button)
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            titleLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 32),
            ])
        
        view.addSubview(indicator)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -32),
            button.heightAnchor.constraint(equalToConstant: 80),
            button.widthAnchor.constraint(equalToConstant: 100)
            ])
    }
    
    @objc
    func close() {
        self.view.antiObscure {
            self.dismiss(animated: true)
        }
    }
    
    func renderStatistic(goodQuantity: Int) {
        self.configurePopup()
        self.view.obscure()
        self.indicator.startShow(for: (Double(goodQuantity), Double(goodQuantity)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.onGetQuantityOfGood()
    }
    
    
}
