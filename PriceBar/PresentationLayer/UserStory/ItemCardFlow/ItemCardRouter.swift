//
//  ItemCardRouter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/26/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


protocol ItemCardRouter: BaseRouter {
    
    func openPickerController(presenter: PickerControlDelegate, currentIndex: Int, dataSource: [PickerData])
}


class ItemCardRouterImpl: ItemCardRouter {
    
    weak var fromVC: ItemCardView!
    
    func openPickerController(presenter: PickerControlDelegate, currentIndex: Int, dataSource: [PickerData]) {
        
        let picker = PickerControl(delegate: presenter, dataSource: dataSource, currentIndex: currentIndex)
        
        self.presentController(fromModule: fromVC, to: picker)
        
        
        
    }
    
    
}
