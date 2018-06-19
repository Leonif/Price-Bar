//
//  ShoplistRouter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

protocol ShoplistRouter {
    func openStatistics()
    func openUpdatePrice(for productId: String, currentPrice: Double, outletId: String)
    func openIssue(with issue: String)
    func openItemCard(for item: DPShoplistItemModel, outletId: String)
    func openScanner()
    func openItemList(for outletId: String)
    func openOutletList()
}


class ShoplistRouterImpl: ShoplistRouter {
    
    
    weak var fromVC: ShoplistView!
    var repository: Repository!
    
    func openStatistics() {
        let statVC = BaseStatisticsVC()
        statVC.modalPresentationStyle = .overCurrentContext
        statVC.repository = repository
        
        DispatchQueue.main.async {
            (self.fromVC as! UIViewController).present(statVC, animated: true)
        }
    }
    
    func openUpdatePrice(for productId: String, currentPrice: Double, outletId: String) {
        let vc = UpdatePriceVC(nib: R.nib.updatePriceVC)
        vc.productId = productId
        vc.price = currentPrice
//        vc.data = data
        vc.onSavePrice = { [weak self] in
            self?.fromVC.onSavePrice()
        }
        (self.fromVC as! UIViewController).present(vc, animated: true)

    }
    
    func openIssue(with issue: String) {
        func openIssueVC(issue: String) {
            let vc = IssueVC(nib: R.nib.issueVC)
            vc.issueMessage = issue
//            vc.onTryAgain = { [weak self] in
//                self?.fromVC.onTryAgain()
//            }
            (self.fromVC as! UIViewController).present(vc, animated: true)
        }
    }
    
    func openItemCard(for item: DPShoplistItemModel, outletId: String) {
        let vc = ItemCardNew(nib: R.nib.itemCardNew)
        vc.item = item
        vc.repository = repository
        vc.outletId = outletId
        
        (self.fromVC as! UIViewController).present(vc, animated: true)

    }
    
    func openScanner() {
        let vc = R.storyboard.main.scannerController()!
        vc.delegate = self as! ScannerDelegate
        (self.fromVC as! UIViewController).navigationController?.pushViewController(vc, animated: true)
    }
    
    func openItemList(for outletId: String) {
        let vc = R.storyboard.main.itemListVC()!
        vc.delegate = fromVC as? ItemListVCDelegate
        vc.outletId = outletId
        vc.repository = repository
        (self.fromVC as! UIViewController).navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func openOutletList() {
        let vc = R.storyboard.main.outletsVC()!
        vc.delegate = self as? OutletVCDelegate
        (self.fromVC as! UIViewController).navigationController?.pushViewController(vc, animated: true)

    }
}







struct DataStorage {
    var repository: Repository
    var vc: UIViewController
    var outlet: Outlet?
}

//protocol IssueRoute {
//    func onTryAgain()
//}
//
//extension IssueRoute where Self: UIViewController {
//    func openIssueVC(issue: String) {
//        let vc = IssueVC(nib: R.nib.issueVC)
//        vc.issueMessage = issue
//        vc.onTryAgain = {
//            self.onTryAgain()
//        }
//        self.present(vc, animated: true)
//    }
//}
//
//
//
//
//
//
//protocol ItemCardRoute {
//}
//
//extension ItemCardRoute where Self: UIViewController {
//    func openItemCard(for item: DPShoplistItemModel, data: DataStorage) {
//        let vc = ItemCardNew(nib: R.nib.itemCardNew)
//        vc.item = item
//        vc.delegate = data.vc as! ItemCardVCDelegate
//        vc.repository = data.repository
//        vc.outletId = data.outlet?.id
//        
//        self.present(vc, animated: true)
//    }
//    
//    func openScannedNewItemCard(for barcode: String, data: DataStorage) {
//        let vc = ItemCardNew(nib: R.nib.itemCardNew)
//        vc.barcode = barcode
//        vc.item = nil
//        vc.delegate = data.vc as! ItemCardVCDelegate
//        vc.repository = data.repository
//        vc.outletId = data.outlet?.id
//        self.present(vc, animated: true)
//    }
//}
//
//
//protocol ItemListRoute {
//    var data: DataStorage! { get }
//}
//
//
//extension ItemListRoute where Self: UIViewController {
//    func openItemList(for outletId: String) {
//        let vc = R.storyboard.main.itemListVC()!
//        vc.delegate = self as? ItemListVCDelegate
//        vc.outletId = outletId
//        vc.itemCardDelegate = self as? ItemCardVCDelegate
//        vc.repository = data.repository
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//    
//}
//
//
//protocol UpdatePriceRoute {
//    func onSavePrice()
//}
//
//extension UpdatePriceRoute where Self: UIViewController {
//    func openUpdatePrice(for productId: String, currentPrice: Double = 0.0,  data: DataStorage) {
//        let vc = UpdatePriceVC(nib: R.nib.updatePriceVC)
//        vc.productId = productId
//        vc.price = currentPrice
//        vc.data = data
//        vc.onSavePrice = { [weak self] in
//            self?.onSavePrice()
//        }
//        self.present(vc, animated: true)
//    }
//}
//
//
//protocol StatisticsRoute {
//    var data: DataStorage! { get }
//}
//
////extension StatisticsRoute where Self: UIViewController {
////    func openStatistics(data: DataStorage) {
////        let statVC = BaseStatisticsVC()
////        statVC.modalPresentationStyle = .overCurrentContext
////        statVC.repository = self.data.repository
////
////        DispatchQueue.main.async {
////            self.present(statVC, animated: true)
////        }
////    }
////}
//
//protocol ScannerRoute {
//    
//}
//
//
//extension ScannerRoute where Self: UIViewController {
//    func openScanner() {
//        let vc = R.storyboard.main.scannerController()!
//        vc.delegate = self as! ScannerDelegate
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//
//protocol OutletListRoute {
//}
//
//
//extension OutletListRoute where Self: UIViewController {
//    func openOutletLst() {
//        let vc = R.storyboard.main.outletsVC()!
//        vc.delegate = self as? OutletVCDelegate
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}


