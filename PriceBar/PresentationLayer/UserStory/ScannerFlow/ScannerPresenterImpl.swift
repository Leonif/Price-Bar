//
//  ScannerPresenterImpl.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import AVFoundation


protocol ScannerOutput {
    func scanned(barcode: String)
}



protocol ScannerPresenter {
    func onCheckAccess()
    func onSendCodeOutside(code: String)
}


class ScannerPresenterImpl: ScannerPresenter {
    
    weak var view: ScannerView!
    var scannerOutput: ScannerOutput!
    
    func onCheckAccess() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if  authStatus == AVAuthorizationStatus.denied {
            // TODO: localize it
            self.view.onError(with: "You deined camera access")
            
        } else {
            self.view.onCameraAccessChecked()
        }
    }
    
    
    func onSendCodeOutside(code: String) {
        self.scannerOutput.scanned(barcode: code)
    }
    
    
}
