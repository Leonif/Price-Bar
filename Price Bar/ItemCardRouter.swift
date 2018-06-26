//
//  ItemCardRouter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/26/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


protocol ItemCardRouter: BaseRouter {
    
    func openPickerController()
}


class ItemCardRouterImpl: ItemCardRouter {
    
    
    func openPickerController() {
        func onPickerUpdated(currentIndex: Int, dataSource: [PickerData]) {
            let picker = PickerControl(delegate: self,
                                       dataSource: dataSource,
                                       currentIndex: currentIndex)
            self.present(picker, animated: true, completion: nil)
        }
    }
    
    
}
