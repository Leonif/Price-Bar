//
//  ShopItemCell.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

protocol WeightCellDelegate {
    func selectedWeight(sender: ShopItemCell, weight: Double)
}


class ShopItemCell: UITableViewCell {
    
    
    @IBOutlet weak var imageItem: UIImageView!
    @IBOutlet weak var nameItem: UILabel!
    @IBOutlet weak var priceItem: UILabel!
    @IBOutlet weak var quantityItem: UILabel!
    @IBOutlet weak var totalItem: UILabel!
    @IBOutlet weak var uomLabel: UILabel!
    @IBOutlet weak var checkMarkBtn: UIButton!
    @IBOutlet weak var quantitySlider: UISlider!
    @IBOutlet weak var weightView: CollectionFreeView! {
        didSet { createWeightLine() }
    }
    var delegate: WeightCellDelegate?
    var weightList = [Double]()
    var currentIndex = 0
    
    
    var views = [UIView]()
    
    func createWeightLine() {
        weightView.horizontall = true
        weightView.cellBackgroundColor = .clear
        weightView.squareKoeff = 0.7
        weightView.isFramed = false
        weightView.spaceBetweenView = 0
        weightView.delegate = self
        
        for i in 0...1000 {
            let w = Double(i) * 0.01
            weightList.append(w)
            views.append(createCell(for: w))
        }
        weightView.views = views
    }
    
    
    
    func createCell(for weight: Double) -> UIView {
        let label = UILabel()
        
        label.text = "\(weight)"
        label.size(14)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let weightView = UIView()
        weightView.layer.cornerRadius = 20
        //weightView.clipsToBounds = true
        //label.layer.cornerRadius = 20
        
        
        weightView.backgroundColor = .blue
        weightView.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: weightView.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: weightView.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: weightView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: weightView.bottomAnchor).isActive = true
        
        return weightView
    }
    
    
    
    func configureCell(item: ShopItem) {
        let s = item
        
        if s.itemUom.isPerPiece {
            quantitySlider.isHidden = false
            weightView.isHidden = true
        } else {
            quantitySlider.isHidden = true
            weightView.isHidden = false
        }
        
        let checkAlpha = CGFloat(s.checked ? 0.5 : 1)
        self.contentView.alpha = checkAlpha
        let imageStr = s.checked ? CheckMark.check.rawValue : CheckMark.uncheck.rawValue
        
        checkMarkBtn.setImage(UIImage(named: imageStr), for: .normal)
        
        nameItem.text = s.name
        priceItem.text = "\(s.price.asLocaleCurrency)"
        quantityItem.text = String(format:"%.2f", s.quantity)
        uomLabel.text = s.itemUom.name
        
        quantitySlider.value = Float(s.quantity)
        totalItem.text = s.total.asLocaleCurrency
        
    }
}





extension ShopItemCell: CollectionFreeViewDelegate {
    
    func selectedCell(by index: Int) {
        
        views[currentIndex].backgroundColor = .blue
        
        views[index].backgroundColor = .red
        
        currentIndex = index
        
        if let delegate = delegate {
            delegate.selectedWeight(sender: self, weight: weightList[index])
        }
    }
    
    func moved(to index: Int) {
        
    }
    
    
}
