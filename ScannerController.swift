//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation



protocol ScannerView: BaseView {
    func onCameraAccessChecked()
}


class ScannerController: UIViewController, UIGestureRecognizerDelegate, AVCaptureMetadataOutputObjectsDelegate, ScannerView {
    var presenter: ScannerPresenter!
    var scannerAdapter: ScannerAdapter!
    @IBOutlet weak var bottomNavigationView: UIView!
    
    
    let backButton: UIButton = {
        let b = UIButton(frame: CGRect.zero)
        let icon = R.image.backButton()
        b.setImage(icon, for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigation()
        self.presenter.onCheckAccess()
        self.view.bringSubview(toFront: bottomNavigationView)

    }
    
    
    private func setupNavigation() {
        self.backButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        
    }
    
    
    
    func onCameraAccessChecked() {
        
        self.scannerAdapter.onCodeTaken = { (code) in
            self.close()
            self.presenter.onSendCodeOutside(code: code)
        }
        
        self.scannerAdapter.onError = { (error) in
            self.onError(with: error)
        }
        
        self.scannerAdapter.viewForCammera = self.view
        
        let bounds = view.layer.bounds
        self.scannerAdapter.configure(frame: bounds)
    }
    
    @objc
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
    

}
