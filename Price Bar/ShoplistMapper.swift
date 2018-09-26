//
//  ShoplistMapper.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 9/17/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation



class ShoplistMapper {
    
    func transform(input: [ShoplistViewItem], categoryList: [String]) -> [ShoplistDataSource] {
        var output: [ShoplistDataSource] = []
        for category in categoryList {
            let items = input.filter { $0.productCategory == category }
            
            if !items.isEmpty {
                output.append(.products(title: category, elements: items))
            }
        }
        
        
        output.append(.notes(title: "Список покупок", elements: [NoteViewItem(note: "Картошка")]))
        
        return output
    }
}
