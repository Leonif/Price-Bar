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
        let buton = UIButton(frame: CGRect.zero)
        let icon = R.image.backButton()
        buton.setImage(icon, for: .normal)
        buton.imageView?.contentMode = .scaleAspectFit

        return buton
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
        self.scannerAdapter.onCodeTaken = { [weak self] (code) in
            self?.close()
            self?.presenter.onSendCodeOutside(code: code)
        }

        self.scannerAdapter.onError = { [weak self] (error) in
            self?.onError(with: error, completion: { [weak self] in
                self?.scannerAdapter.startScaning()
            })
        }
        self.scannerAdapter.viewForCammera = self.view

        let bounds = view.layer.bounds
        self.scannerAdapter.configure(frame: bounds)
        self.scannerAdapter.startScaning()
    }

    @objc
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
}
