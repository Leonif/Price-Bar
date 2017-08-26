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


class ShopItemCell: UITableViewCell,CollectionFreeViewCellDelegate {
    
    
    @IBOutlet weak var imageItem: UIImageView!
    @IBOutlet weak var nameItem: UILabel!
    @IBOutlet weak var priceItem: UILabel!
    @IBOutlet weak var quantityItem: UILabel!
    @IBOutlet weak var totalItem: UILabel!
    @IBOutlet weak var uomLabel: UILabel!
    @IBOutlet weak var checkMarkBtn: UIButton!
    @IBOutlet weak var quantitySlider: UISlider!
    @IBOutlet weak var weightView: CollectionFreeViewCell!
    var delegate: WeightCellDelegate?
    var weightList = [Double]()
    
    
    var views = [UIView]()
    
    
    func selectedCell(by index: Int) {
        if let delegate = delegate {
            delegate.selectedWeight(sender: self, weight: weightList[index])
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
      weightView.delegate = self
        
        for i in 0...100 {
            let weight = UIView()
            weight.backgroundColor = .lightGray
            let label = UILabel()
            
            let w = Double(i) * 0.1
            weightList.append(w)
            
            
            label.text = "\(w)"
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            weight.addSubview(label)
            label.leftAnchor.constraint(equalTo: weight.leftAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: weight.rightAnchor).isActive = true
            label.topAnchor.constraint(equalTo: weight.topAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: weight.bottomAnchor).isActive = true
            views.append(weight)
        }
        weightView.views = views
        weightView.horizontall = true
        weightView.squareKoeff = 0.7
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
