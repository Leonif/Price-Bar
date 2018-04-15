//
//  ItemCardNew.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/15/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

class ItemCardNew: UIViewController {

    @IBOutlet weak var itemName: UITextField!
    @IBOutlet weak var itemBrand: UITextField!
    @IBOutlet weak var itemWeight: UITextField!
    @IBOutlet weak var itemUom: UITextField!
    @IBOutlet weak var itemPrice: UITextField!
    @IBOutlet weak var itemCategory: UITextField!
    
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    
    var activeField: UITextField!
    var lastOffset: CGPoint!
    var keyboardHeight: CGFloat!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        [itemName, itemBrand, itemWeight, itemUom, itemPrice, itemCategory].forEach {
            PriceBarStyles.grayBorderedRoundedView.apply(to: $0!)
            $0!.delegate = self
            self.addToolBar(textField: $0!)
        }
        
        
        // Observe keyboard change
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Add touch gesture for contentView
        self.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
        
        
    }
    
    @objc
    func returnTextView(gesture: UIGestureRecognizer) {
        guard activeField != nil else {
            return
        }
        
        activeField?.resignFirstResponder()
        activeField = nil
    }
    
    
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.constraintContentHeight.constant -= self.keyboardHeight
            self.scrollView.contentOffset = self.lastOffset
        }
        keyboardHeight = nil
    }
    
        
        
    @objc
    func keyboardWillShow(notification: NSNotification) {
        
        if self.keyboardHeight != nil {
            return
        }
        
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardSize.height
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintContentHeight.constant += self.keyboardHeight
            })
            // move if keyboard hide input field
            let distanceToBottom = self.scrollView.frame.size.height - (activeField?.frame.origin.y)! - (activeField?.frame.size.height)!
            let collapseSpace = keyboardHeight - distanceToBottom
            if collapseSpace < 0 {
                // no collapse
                return
            }
            // set new offset for scroll view
            UIView.animate(withDuration: 0.3, animations: {
                // scroll to the position above keyboard 10 points
                self.scrollView.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10 + self.activeField.inputAccessoryView!.frame.height)
            })
        }
    }
    
    
    
    @IBAction func onCloseTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    
    
    
}

extension ItemCardNew {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        lastOffset = self.scrollView.contentOffset
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    
}
