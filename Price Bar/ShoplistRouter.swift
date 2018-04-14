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

    var vc: UpdatePriceVC!
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
    
    
    
    func openUpdatePrice(for productId: String, data: DataStorage) {
        self.vc = UpdatePriceVC(nib: R.nib.updatePriceVC)
        self.vc.productId = productId
        self.vc.data = data
        data.vc.present(self.vc, animated: true)
        self.vc.onSavePrice = { [weak self] in
            self?.onSavePrice?()
        }
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
        if segue.identifier == Strings.Segues.showEditItem.name,
            let itemCardVC = segue.destination as? ItemCardVC {
            if let item = sender as? DPShoplistItemModel {
                itemCardVC.item = item
                itemCardVC.delegate = data.vc as! ItemCardVCDelegate
                itemCardVC.repository = data.repository
                itemCardVC.outletId = data.outlet?.id
            }
        }
        
        if let typedInfo = R.segue.shopListController.scannedNewProduct(segue: segue) {
            if let barcode = sender as? String, let outlet = data.outlet {
                typedInfo.destination.barcode = barcode
                typedInfo.destination.delegate = data.vc as! ItemCardVCDelegate
                typedInfo.destination.repository = data.repository
                typedInfo.destination.outletId = outlet.id
            }
        }
        
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

