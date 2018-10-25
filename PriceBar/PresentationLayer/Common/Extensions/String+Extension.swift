//
//  OwnString+Extension.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 4/12/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation

extension String {

    func numberFormatting() -> Double? {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        if let number = formatter.number(from: self) {
            return Double(truncating: number)
        } else {
            formatter.decimalSeparator = ","
            if let number = formatter.number(from: self) {
                return Double(truncating: number)
            }
        }
        return nil
    }

}

extension String {
    // types of format sting
    //http://userguide.icu-project.org/formatparse/datetime
    private var currentTimeZone: TimeZone {
        return TimeZone.current
    }

    func toDate(with format: String) -> Date? {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = currentTimeZone
        return dateFormatter.date(from: self)
    }
}
extension String {
    var double: Double {
        return Double(self)!
    }
}
