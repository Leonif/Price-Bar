//
//  OutletsVC.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 6/14/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import UIKit

class OutletsVC: UIViewController {
    
    
    var outlets = [Outlet]()
    var delegate: Exchange!
    @IBOutlet weak var outletTableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadOultets {
            self.outletTableView.reloadData()
        }
        
    }

    
}


extension  OutletsVC {
    func loadOultets(completed: @escaping ()->()) {
        let baseUrl = "https://api.foursquare.com/v2/venues/"
        let clientId = "NPJDKUKZLFXDST4QCKJXWPLVYC3MCDSEQVQKEBMEZL1WETJM"
        let clientSecret = "MA2OS055BLYF3XOUMXRHWTBBJYGYX3U33VVJE3A4VSYBTJ0X"
        let category = "4bf58dd8d48988d1f9941735" //Food & Drink Shop
        let location = (50.412822, 30.635047)
        
        let requestURL = baseUrl + "search?categoryId=\(category)&ll=\(location.0),\(location.1)&radius=1000&intent=browse&client_id=\(clientId)&client_secret=\(clientSecret)&v=20170614"
        
        let url = URL(string: requestURL)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
                print(error ?? "")
            } else {
                do {
                    if let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]  {
                        if let resp = parsedData["response"] as? [String: Any]  {
                            if let venues = resp["venues"] as? [[String:Any]] {
                                for v in venues {
                                    if let id = v["id"] as? String, let name = v["name"] as? String, let loc = v["location"] as? [String:Any]  {
                                        if let add = loc["address"] as? String, let dist = loc["distance"] as? Double {
                                            print(id, name, add, dist)
                                            self.outlets.append(Outlet(id, name, add, dist))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async() {//go into UI
                        completed()
                    }
                    
                } catch let error as NSError {
                        print(error)
                    }
                
            }
            
        }.resume()

    }
}


extension OutletsVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outlets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.itemChanged(object: outlets[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = outletTableView.dequeueReusableCell(withIdentifier: "OutletCell", for: indexPath) as? OutletCell {
            
            let outlet = outlets[indexPath.row]
                cell.configureCell(outlet: outlet)
                return cell
            
            
        }
        
        
        
        return UITableViewCell()
    }
}
