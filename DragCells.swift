//
//  DragCells.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/28/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import UIKit

//MARK: Drag cells into other category and between each others
extension ShopListController {
    
    func initDragMode() {
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
        shopTableView.addGestureRecognizer(longpress)
        
    }
    
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        //        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        //        let state = longPress.state
        //        let locationInView = longPress.location(in: shopTableView)
        //        let indexPath = shopTableView.indexPathForRow(at: locationInView)
        //
        //        struct My {
        //            static var cellSnapshot : UIView? = nil
        //        }
        //        struct Path {
        //            static var initialIndexPath : IndexPath? = nil
        //        }
        //
        //        switch state {
        //        case UIGestureRecognizerState.began:
        //            if indexPath != nil {
        //                Path.initialIndexPath = indexPath
        //                let cell = shopTableView.cellForRow(at: indexPath!) as UITableViewCell!
        //                My.cellSnapshot = snapshopOfCell(inputView: cell!)
        //                var center = cell?.center
        //                My.cellSnapshot!.center = center!
        //                My.cellSnapshot!.alpha = 0.0
        //                shopTableView.addSubview(My.cellSnapshot!)
        //
        //                UIView.animate(withDuration: 0.25, animations: { () -> Void in
        //                    center?.y = locationInView.y
        //                    My.cellSnapshot!.center = center!
        //                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        //                    My.cellSnapshot!.alpha = 0.98
        //                    cell?.alpha = 0.0
        //
        //                }, completion: { (finished) -> Void in
        //                    if finished {
        //                        cell?.isHidden = true
        //                    }
        //                })
        //            }
        //        case UIGestureRecognizerState.changed:
        //
        //            if var center = My.cellSnapshot?.center {
        //                center.y = locationInView.y
        //                My.cellSnapshot!.center = center
        //                if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
        //                    //change places
        //                    if let a = shopList.getItem(index: indexPath!), let b = shopList.getItem(index: Path.initialIndexPath!) {
        //
        //                        if let c = b.copy() as? ShopItem {
        //
        //                            c.category = a.category
        //                            shopList.remove(item: b)
        //                            shopList.append(item: c)
        //
        //                            //  shopTableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
        //                            Path.initialIndexPath = indexPath
        //                            shopTableView.reloadData()
        //
        //                        }
        //                    }
        //                }
        //            }
        //
        //
        //        default:
        //            if let pIndex = Path.initialIndexPath, let cell = shopTableView.cellForRow(at:pIndex) {
        //                cell.isHidden = false
        //                cell.alpha = 0.0
        //                UIView.animate(withDuration: 0.25, animations: { () -> Void in
        //                    My.cellSnapshot!.center = cell.center
        //                    My.cellSnapshot!.transform = CGAffineTransform.identity
        //                    My.cellSnapshot!.alpha = 0.0
        //                    cell.alpha = 1.0
        //                }, completion: { (finished) -> Void in
        //                    
        //                    if finished {
        //                        Path.initialIndexPath = nil
        //                        My.cellSnapshot!.removeFromSuperview()
        //                        My.cellSnapshot = nil
        //                    }
        //                })
        //            }
        //        }
        //        
    }
}
