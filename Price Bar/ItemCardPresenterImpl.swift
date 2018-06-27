//
//  ItemCardPresenterImpl.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


enum PickerType {
    case category, uom
}



protocol ItemCardPresenter {
 
    func onCategoryPressed(currentCategory: String)
    func onUomPressed(currentUom: String)
    func onUpdateOrCreateProduct(product: DPUpdateProductModel)
    
}

class ItemCardPresenterImpl: ItemCardPresenter {
    weak var view: ItemCardView!
    var repository: Repository!
    var router: ItemCardRouter!
    var pickerType: PickerType = .category
    
    
    
    func onUpdateOrCreateProduct(product: DPUpdateProductModel) {
        // define is ths product exists by id
        // if yeas - update
        //else create
    }
    
    
    func onCategoryPressed(currentCategory: String) {

        var pickerData: [PickerData] = []
        var curentIndex = 0
        
        self.pickerType = .category
        
        //load categories
        guard let dpCategoryList = repository.getCategoryList() else {
            fatalError("Category list is empty")
        }
        
        let categories = dpCategoryList.map { CategoryMapper.mapper(from: $0) }
        
        
        for (index, category) in categories.enumerated() {
            if category.name == currentCategory {
                curentIndex = index
            }
            pickerData.append(PickerData(id: category.id, name: category.name))
        }
        
        self.router.openPickerController(presenter: self, currentIndex: curentIndex, dataSource: pickerData)

    }
    
    func onUomPressed(currentUom: String) {
        var pickerData: [PickerData] = []
        var curentIndex = 0
        
        self.pickerType = .uom
        
        guard let dpUomList = repository.getUomList() else {
            fatalError("Category list is empty")
        }
        
        for (index, uom) in dpUomList.enumerated() {
            if uom.name == currentUom {
                curentIndex = index
            }
            pickerData.append(PickerData(id: uom.id, name: uom.name))
        }
        
        self.router.openPickerController(presenter: self, currentIndex: curentIndex, dataSource: pickerData)
    }
    
}


extension ItemCardPresenterImpl: PickerControlDelegate {
    func choosen(id: Int32) {
        if pickerType == .category {
            guard let name = repository.getCategoryName(category: id) else { return }
            self.view.onCategoryChoosen(name: name)
        } else {
            guard let name = repository.getUomName(for: id) else { return }
            self.view.onUomChoosen(name: name)
            
        }
    }
}



