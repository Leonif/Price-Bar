//
//  Extension.swift
//  devslopes-social
//
//  Created by Leonid Nifantyev on 7/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import UIKit

//extension UITextField {
//    func animateViewMoving (up: Bool, moveValue: CGFloat, view: UIView) {
//        let movementDuration: TimeInterval = 0.3
//        let movement: CGFloat = (up ? -moveValue : moveValue)
//        UIView.beginAnimations("animateView", context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.setAnimationDuration(movementDuration)
//        view.frame = view.frame.offsetBy(dx: 0, dy: movement)
//        UIView.commitAnimations()
//    }
//}

extension Date {

    func getString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: TimeZone.current.abbreviation() ?? "")
        return formatter.string(from: self)
    }

    var dayOfWeek: Int {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: self)
        let weekDay = myComponents.weekday
        return weekDay!
    }
}


extension Bool {
    mutating func toggle() {
        self = !self
    }
}

extension UISearchBar {
    var textField: UITextField {
        guard let tf = (value(forKey: "searchField") as? UITextField) else { fatalError() }
        return tf
    }
    
    func addToolBar() {
        //Add done button to numeric pad keyboard
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let flex = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
                                        target: self, action: nil)
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done,
                                              target: self, action: #selector(numDonePressed))
        
        toolbarDone.items = [flex, barBtnDone] // You can even add cancel button too
        self.inputAccessoryView = toolbarDone
    }
    
    @objc
    func numDonePressed() {
        self.resignFirstResponder()
    }
}

extension UILabel {
    func size(_ size: CGFloat) {
        self.font = UIFont(name: self.font.fontName, size: size)
    }
}
