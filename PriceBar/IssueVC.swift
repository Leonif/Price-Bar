//
//  IssueVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 5/1/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

class IssueVC: UIViewController {
    @IBOutlet private weak var issueLabel: UILabel!
    @IBOutlet private weak var issueButton: UIButton!
    
    var onTryAgain: (() -> Void)? = nil
    
    var issueMessage: String = ""
    var buttonTitle: String = R.string.localizable.common_clear()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.issueLabel.text = self.issueMessage
        self.issueButton.setTitle(self.buttonTitle, for: .normal)
        PriceBarStyles.grayBorderedRounded.apply(to: self.issueButton)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurEffectView, at: 0)
    
    }

    @IBAction func issueButtonTapped(sender: Any) {
        self.dismiss(animated: true, completion: { [weak self] in
            self?.onTryAgain?()
        })
    }
    

}
