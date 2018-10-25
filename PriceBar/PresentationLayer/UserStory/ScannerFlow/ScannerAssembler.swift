//
//  ScannerAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

class ScannerAssembler {

    func assemble(scannerOutput: ScannerOutput) -> BaseView {

        let presenter = ScannerPresenterImpl()
        let view = R.storyboard.main.scannerController()!
        let scannerAdapter = ScannerAdapter()

        view.presenter = presenter
        view.scannerAdapter = scannerAdapter

        presenter.view = view
        presenter.scannerOutput = scannerOutput

        return view

    }
}
