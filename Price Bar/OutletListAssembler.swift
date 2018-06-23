//
//  OutletListAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/23/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation


class OutletListAssembler {
    
    
    func assemble(outletListOutput: OutletListOutput) -> BaseView {
        let view = R.storyboard.main.outletsVC()!

        let adapter = OutetListAdapter()
        view.adapter = adapter
        
        
        let presenter = OutletListPresenterImpl()
        
        presenter.outletService = OutletService()
        presenter.outletListOutput = outletListOutput
        
        presenter.view = view
        view.presenter = presenter
        
        return view
    }
    
}
