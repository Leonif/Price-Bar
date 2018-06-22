//
//  BaseRouter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/22/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

protocol BaseRouter {
    
}


extension BaseRouter {
    func presentModule(fromModule: BaseView, toModule: BaseView) {
        (fromModule as! UIViewController).present(toModule as! UIViewController, animated: true)
    }
    func pushModule(fromModule: BaseView, toModule: BaseView) {
        (fromModule as! UIViewController).navigationController?.pushViewController(toModule as! UIViewController, animated: true)
    }
}
