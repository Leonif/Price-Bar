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
    func openUpdatePrice(for productId: String, currentPrice: Double, outletId: String)
    func openIssue(with issue: String)
    func openItemCard(for item: ShoplistItem, outletId: String)
    func openScanner()
    func openItemList(for outletId: String)
    func openOutletList(presenter: ShoplistPresenter)
}


class ShoplistRouterImpl: ShoplistRouter {
    
    

    weak var fromVC: ShoplistView!
    var repository: Repository!
    
    func openStatistics() {
        let module = CloudStatisticsAssembler().assemble()
        self.presentModule(fromModule: fromVC, toModule: module)
    }
    
    func openUpdatePrice(for productId: String, currentPrice: Double, outletId: String) {
        let module = UpdatePriceAssembler().assemble(productId: productId, outletId: outletId)
        self.presentModule(fromModule: fromVC, toModule: module)
    }
    
    func openIssue(with issue: String) {
        func openIssueVC(issue: String) {
            let vc = IssueVC(nib: R.nib.issueVC)
            vc.issueMessage = issue
            self.presentModule(fromModule: fromVC, toModule: vc as! BaseView)
        }
    }
    
    func openItemCard(for item: ShoplistItem, outletId: String) {
        let vc = ItemCardNew(nib: R.nib.itemCardNew)
        vc.item = item
        vc.repository = repository
        vc.outletId = outletId
        
        self.presentModule(fromModule: fromVC, toModule: vc as! BaseView)
    }
    
    func openScanner() {
        let vc = R.storyboard.main.scannerController()!
        vc.delegate = self as! ScannerDelegate
        self.pushModule(fromModule: fromVC, toModule: vc as! BaseView)
    }
    
    func openItemList(for outletId: String) {
        let vc = R.storyboard.main.itemListVC()!
        vc.delegate = fromVC as? ItemListVCDelegate
        vc.outletId = outletId
        vc.repository = repository
        self.pushModule(fromModule: fromVC, toModule: vc)
    }
    
    
    func openOutletList(presenter: ShoplistPresenter) {
        let module = OutletListAssembler().assemble(outletListOutput: presenter)
        self.pushModule(fromModule: fromVC, toModule: module)
    }
}


