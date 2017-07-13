//
//  FirebaseService.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 7/7/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import Firebase

let DB_FIRBASE = Database.database().reference()

class FirebaseService {
    
   
    static let data = FirebaseService()
    var REF_BASE = DB_FIRBASE
    var REF_GOODS = DB_FIRBASE.child("goods")
    var REF_CATEGORIES = DB_FIRBASE.child("categories")
    
    
    func loginToFirebase(_ success: @escaping ()->(), _ error: ()->()) {
        
        let email = "good_getter@gmail.com"
        let pwd = "123456"
        
        
        Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
            if error != nil {
                print("error of Email authorization!")
                Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                    if error != nil {
                        print("error of user creation!")
                        return
                    }
                    print("User \(email) is created!")
                    
                    return
                    
                })
            }
            success()
            print("Email authorization is successful!")
            
            
            
        })
        

    }
    
    
    
    func loadGoods(goodList: @escaping (_ good: ShopItem)->(), completition: @escaping ()->())  {
        
        loginToFirebase({ 
            self.REF_GOODS.observe(.value, with: { (snapshot) in
                if let snapGoods = snapshot.value as? [String: Any] {
                    for snapGood in snapGoods {
                        if let goodDict = snapGood.value as? Dictionary<String, Any> {
                            let key = snapGood.key
                            let good = ShopItem(id: key, goodData: goodDict)
                            goodList(good)
                        }
                    }
                    completition()
                }
            })
        }) { 
            print("Error goods getting")
        }
    }
    
    
    func exportToCloud(_ itemList: [ShopItem]) {
        
        //before write, check if it exists in FireBase
        
        
    }
    
}
