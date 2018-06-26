//
//  ItemListAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class ItemListAssembler {
    
    func assemble(for outletId: String, itemListOutput: ItemListOutput) -> BaseView {
        
        let repository = Repository()
        
        let presenter = ItemListPresenterImpl()
        presenter.itemListOutput = itemListOutput
        presenter.repository = repository
        
        let adapter = ItemListAdapter()
        
        let view = R.storyboard.main.itemListVC()!
        
        view.adapter = adapter
        view.outletId = outletId
        view.presenter = presenter
        
        presenter.view = view
        
        return view
    }
}
