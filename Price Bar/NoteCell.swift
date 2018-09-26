//
//  NoteCell.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 9/25/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell, NibLoadableReusable {

    @IBOutlet weak private var noteTextView: UITextView!
    
    func configure(note: String) {
        noteTextView.text = note
    }
    
}
