//
//  LoginAssembler.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 11/9/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import UIKit

class LoginAssembler {
    
    func assemble() -> UIViewController {
        
        let view = R.storyboard.main.loginVC()!
        
        
        return view
    }
    
}
