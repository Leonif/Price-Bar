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


class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, ScannerView {
//    var delegate: ScannerDelegate!
    
    var presenter: ScannerPresenter!
    var scannerAdapter: ScannerAdapter!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter.onCheckAccess()
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
        self.scannerAdapter.configure(frame: view.layer.bounds)
    }
    
    
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
    

}
