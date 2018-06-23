//
//  ScannerPresenterImpl.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/24/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import AVFoundation


protocol ScannerPresenter {
    func onCheckAccess()
}


class ScannerPresenterImpl: ScannerPresenter {
    
    weak var view: ScannerView!
    
    func onCheckAccess() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if  authStatus == AVAuthorizationStatus.denied {
            self.view.onError(with: "You deined camera access")
            
        } else {
            self.view.onCameraAccessChecked()
        }
    }
}
