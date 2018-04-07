//
//  SyncAnimator.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 3/18/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import UIKit

class SyncAnimator {
    var progressVC: UIViewController!
    var circleIndicator: CircleIndicator!
    var title: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.text = R.string.localizable.sync_process()
        return lbl
    }()
    var parent: UIViewController!
    
    init(parent: UIViewController) {
        self.progressVC = UIViewController()
        self.parent = parent
        progressVC.modalPresentationStyle = .overCurrentContext
        progressVC.view.backgroundColor = .gray
        
        let size: CGFloat = 200
        let lineThickness: CGFloat = 12
        
        let rect = CGRect(x: self.parent.view.center.x - size / 2,
                          y: self.parent.view.center.y - size / 2,
                          width: size, height: size)
        
        circleIndicator = CircleIndicator(frame: rect)
        circleIndicator.decorate(titleColor: .white, colors: (.clear, .gray), lineWidth: lineThickness)
        circleIndicator.type = .justUpdate
        progressVC.view.addSubview(circleIndicator)
        
        let lblRect = CGRect(x: 0, y: 32, width: progressVC.view.bounds.width, height: 100)
        
        title.frame = lblRect
        progressVC.view.addSubview(title)
    }

    func syncHandle(for progress: Double, and max: Double, with text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.circleIndicator.startShow(for: (progress, max))
            self?.title.text = "\(text)"
        }
    }
    
    func startProgress() {
        DispatchQueue.main.async { [weak self] in
            guard let vc = self?.progressVC else { return }
            vc.view.obscure()
            self?.parent.present(vc,
                                 animated: true,
                                 completion: nil)
        }
    }
    
    func stopProgress(completion: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
            self?.progressVC.view.antiObscure { [weak self] in
                self?.progressVC.dismiss(animated: true, completion: nil)
                completion()
            }
        })
        
    }
}
