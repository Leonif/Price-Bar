//
//  BaseRouter.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/22/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

protocol BaseRouter {}

extension BaseRouter {
    func presentController(fromModule: BaseView, to controller: UIViewController) {
        (fromModule as? UIViewController)?.present(controller, animated: true)
    }

    func presentModule(fromModule: BaseView, toModule: UIViewController) {
        (fromModule as? UIViewController)?.present(toModule, animated: true)
    }

    func presentModule(fromModule: BaseView, toModule: BaseView) {
        guard let safeModule = toModule as? UIViewController else {
            debugPrint("Not posible to make trasition to \(toModule)")
            return
        }
        (fromModule as? UIViewController)?.present(safeModule, animated: true)
    }
    func pushModule(fromModule: BaseView, toModule: BaseView) {
        guard let safeModule = toModule as? UIViewController else {
            debugPrint("Not posible to make trasition to \(toModule)")
            return
        }
        (fromModule as? UIViewController)?.navigationController?.pushViewController(safeModule, animated: true)
    }

    func popModule(module: BaseView) {
        (module as? UIViewController)?.navigationController?.popViewController(animated: true)
    }
    func dismiss(module: BaseView) {
        (module as? UIViewController)?.dismiss(animated: true)
    }
}
