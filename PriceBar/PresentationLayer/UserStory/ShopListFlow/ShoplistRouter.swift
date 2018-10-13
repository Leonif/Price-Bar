//
//  ShoplistRouter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

protocol ShoplistRouter: BaseRouter {
    func openStatistics()
    func openUpdatePrice(presenter: ShoplistPresenter, for productId: String, currentPrice: Double, outletId: String)
    func openIssue(with issue: String)
    func openItemCard(presenter: ItemCardDelegate, for productId: String, outletId: String)
    func openScanner(presenter: ShoplistPresenter)
    func openItemList(for outletId: String, presenter: ShoplistPresenter)
    func openOutletList(presenter: ShoplistPresenter)
    func openQuantityController(presenter: QuantityPickerPopupDelegate, quantityEntity: QuantityEntity)
}


class ShoplistRouterImpl: ShoplistRouter {
    weak var fromVC: ShoplistView!
    
    func openStatistics() {
        let module = CloudStatisticsAssembler().assemble()
        self.presentModule(fromModule: fromVC, toModule: module)
    }
    
    func openUpdatePrice(presenter: ShoplistPresenter, for productId: String, currentPrice: Double, outletId: String) {
        let module = UpdatePriceAssembler().assemble(productId: productId, outletId: outletId, updatePriceOutput: presenter)
        self.presentModule(fromModule: fromVC, toModule: module)
    }
    
    func openIssue(with issue: String) {
        let vc = IssueVC(nib: R.nib.issueVC)
        vc.issueMessage = issue
        self.presentModule(fromModule: fromVC, toModule: vc)
    }
    
    func openItemCard(presenter: ItemCardDelegate, for productId: String, outletId: String) {
        let module = ItemCardAssembler().assemble(itemCardDelegate: presenter, for: productId, outletId: outletId)
        self.presentModule(fromModule: fromVC, toModule: module)
    }
    
    func openScanner(presenter: ShoplistPresenter) {
        let module = ScannerAssembler().assemble(scannerOutput: presenter)
        self.pushModule(fromModule: fromVC, toModule: module)
    }
    
    func openItemList(for outletId: String, presenter: ShoplistPresenter) {
        let module = ItemListAssembler().assemble(for: outletId, itemListOutput: presenter)
        self.pushModule(fromModule: fromVC, toModule: module)
    }
    
    
    func openOutletList(presenter: ShoplistPresenter) {
        let module = OutletListAssembler().assemble(outletListOutput: presenter)
        self.pushModule(fromModule: fromVC, toModule: module)
    }
    
    func openQuantityController(presenter: QuantityPickerPopupDelegate, quantityEntity: QuantityEntity) {
        let picker = QuantityPickerPopup(delegate: presenter, model: quantityEntity)
        self.presentController(fromModule: fromVC, to: picker)
    }
}




