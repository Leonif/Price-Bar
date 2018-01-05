//
//  ShopItemCell.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

protocol ShopItemCellDelegate {
    func selectedWeight(for item: ShopItem, weight: Double)
    func checkPressed(for item: ShopItem)
}

enum QuantityType {
    case weight, quantity
}

class ProductQuantitySection {
    
    init(type: QuantityType) {
        
        
    }
    
}



class ShopItemCell: UITableViewCell {
    
    var item: ShopItem?
    
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
    var delegate: ShopItemCellDelegate?
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
        
        weightView.backgroundColor = .blue
        weightView.addSubview(label)
        
        label.leftAnchor.constraint(equalTo: weightView.leftAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: weightView.rightAnchor).isActive = true
        label.topAnchor.constraint(equalTo: weightView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: weightView.bottomAnchor).isActive = true
        
        return weightView
    }
    
    
}

// User react
extension ShopItemCell {
    @IBAction func checkPressed(_ sender: UIButton) {
        
        guard let item = self.item else {
            fatalError("Check pressed for not existed item")
        }
        
        self.item?.checked = !item.checked
        self.checkedState()
        self.delegate?.checkPressed(for: item)
    }
    
    
    @IBAction func sliderChanged(_ sender: UISlider) {
    
        guard let item = self.item else {
            fatalError("Slider changed for not existed item")
        }
        
        let quantity = step(baseValue: Double(sender.value), step: item.itemUom.iterator)
        self.updateWeighOnCell(quantity, item.price)
        self.delegate?.selectedWeight(for: item, weight: quantity)
    
    }
    func step(baseValue: Double, step: Double) -> Double {
        let result = baseValue/step * step
        return step.truncatingRemainder(dividingBy: 1.0) == 0.0 ? round(result) : result
    }
    
    func updateWeighOnCell(_ weight: Double, _ price: Double) {
        
        let total = weight * price
        
        self.quantityItem.text = String(format:"%.2f", weight)
        self.totalItem.text = total.asLocaleCurrency
        
        
    }
    
    
    func checkedState() {
        
        guard let item = self.item else {
            fatalError("Check state for not existed item")
        }
        
        let checkAlpha = CGFloat(item.checked ? 0.5 : 1)
        self.contentView.alpha = checkAlpha
        let imageStr = item.checked ? CheckMark.check.rawValue : CheckMark.uncheck.rawValue
        
        self.checkMarkBtn.setImage(UIImage(named: imageStr), for: .normal)
        
        
    }
    
    
    func configureCell(item: ShopItem) {
        
        self.item = item
        let s = item
        
        if s.itemUom.isPerPiece {
            quantitySlider.isHidden = false
            weightView.isHidden = true
        } else {
            quantitySlider.isHidden = true
            weightView.isHidden = false
        }

        self.checkedState()
        
        nameItem.text = s.name
        priceItem.text = "\(s.price.asLocaleCurrency)"
        uomLabel.text = s.itemUom.name
        self.quantitySlider.value = Float(s.quantity)
        
        self.updateWeighOnCell(s.quantity, s.price)
        
    }
    
    
}






extension ShopItemCell: CollectionFreeViewDelegate {
    
    func selectedCell(by index: Int) {
        views[currentIndex].backgroundColor = .blue
        views[index].backgroundColor = .red
        currentIndex = index
        
        if let delegate = delegate {
            
            guard let item = self.item else {
                fatalError("Weight choosing for not existed item")
            }
            
            let weight = weightList[index]
            
            self.updateWeighOnCell(weight, item.price)
            delegate.selectedWeight(for: item, weight: weight)
        }
    }
    
    func moved(to index: Int) {
        
    }
    
    
}
