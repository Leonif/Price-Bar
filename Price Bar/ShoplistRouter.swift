//
//  ShoplistRouter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/14/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit


struct DataStorage {
    var repository: Repository
    var vc: UIViewController
    var outlet: Outlet?
}


enum ShoplistNextModules {
    case updatePrice
    case statistics
    case productCard
    case productList
    case scanner
    case outletList
    
    
    var viewController: UIViewController? {
        switch self {
        case .updatePrice:
            return UpdatePriceVC(nib: R.nib.updatePriceVC)
        default: return nil
            
        }
    }
    
}




class ShoplistRouter {

    var vc: UIViewController!
    var onSavePrice: (() -> Void)? = nil
    var data: DataStorage!
    
    // MARK: - need to work on it
//    func present(module: ShoplistNextModules, with data: DataStorage) {
//        self.vc = module.viewController
//        self.data = data
//        data.vc.present(self.vc, animated: true)
//        
//
//    }
    
    
    func openItemCard(for item: DPShoplistItemModel, data: DataStorage) {
        let vc = ItemCardNew(nib: R.nib.itemCardNew)
        vc.item = item
        vc.delegate = data.vc as! ItemCardVCDelegate
        vc.repository = data.repository
        vc.outletId = data.outlet?.id
        self.vc = vc
        data.vc.present(self.vc, animated: true)
        
    }
    
    
    func openScannedNewItemCard(for barcode: String, data: DataStorage) {
        let vc = ItemCardNew(nib: R.nib.itemCardNew)
        vc.barcode = barcode
        vc.item = nil
        vc.delegate = data.vc as! ItemCardVCDelegate
        vc.repository = data.repository
        vc.outletId = data.outlet?.id
        self.vc = vc
        data.vc.present(self.vc, animated: true)
        
    }
    
    
    
    func openUpdatePrice(for productId: String, currentPrice: Double = 0.0,  data: DataStorage) {
        let vc = UpdatePriceVC(nib: R.nib.updatePriceVC)
        vc.productId = productId
        vc.price = currentPrice
        vc.data = data
        vc.onSavePrice = { [weak self] in
            self?.onSavePrice?()
        }
        self.vc = vc
        data.vc.present(self.vc, animated: true)
        
    }
    
    func openStatistics(data: DataStorage) {
        let statVC = BaseStatisticsVC()
        statVC.modalPresentationStyle = .overCurrentContext
        self.data = data
        statVC.repository = self.data.repository

        DispatchQueue.main.async {
            self.data.vc.present(statVC, animated: true)
        }
    }
    
    
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?, data: DataStorage) {
//        if segue.identifier == Strings.Segues.showEditItem.name,
//            let itemCardVC = segue.destination as? ItemCardVC {
//            if let item = sender as? DPShoplistItemModel {
//                itemCardVC.item = item
//                itemCardVC.delegate = data.vc as! ItemCardVCDelegate
//                itemCardVC.repository = data.repository
//                itemCardVC.outletId = data.outlet?.id
//            }
//        }
//        
//        if let typedInfo = R.segue.shopListController.scannedNewProduct(segue: segue) {
//            if let barcode = sender as? String, let outlet = data.outlet {
//                typedInfo.destination.barcode = barcode
//                typedInfo.destination.delegate = data.vc as! ItemCardVCDelegate
//                typedInfo.destination.repository = data.repository
//                typedInfo.destination.outletId = outlet.id
//            }
//        }
        
        if let typedInfo = R.segue.shopListController.showOutlets(segue: segue) {
            typedInfo.destination.delegate = data.vc as! OutletVCDelegate
        }
        
        if segue.identifier == Strings.Segues.showItemList.name,
            let itemListVC = segue.destination as? ItemListVC, let outlet = data.outlet {
            itemListVC.outletId = outlet.id
            itemListVC.delegate = data.vc as? ItemListVCDelegate
            itemListVC.itemCardDelegate = data.vc as? ItemCardVCDelegate
            itemListVC.repository = data.repository
            
        }
        if segue.identifier == Strings.Segues.showScan.name,
            let scanVC = segue.destination as? ScannerController {
            scanVC.delegate = data.vc as! ScannerDelegate
        }
    }
}
