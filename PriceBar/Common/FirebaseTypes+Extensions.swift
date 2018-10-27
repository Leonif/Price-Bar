//
//  FirebaseTypes+Extensions.swift
//  PriceBar
//
//  Created by Leonid Nifantyev on 10/27/18.
//  Copyright © 2018 LionLife. All rights reserved.
//

import Foundation
import Firebase


func unbox<U: Decodable, DictionaryType>(from object: DictionaryType) -> U? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
        let entity = try JSONDecoder().decode(U.self, from: jsonData)
        return entity
    } catch let error {
        debugPrint(error)
        return nil
    }
}

extension DatabaseReference {
    func makeArrayRequest<U: Decodable>(completion: @escaping (U) -> Void) {
        self.observeSingleEvent(of: .value, with: { snapshot in
            guard let array = snapshot.children.allObjects as? [DataSnapshot] else { return }
            let object = array.compactMap { $0.value as? [String: Any] }
            guard let entityArray: U = unbox(from: object) else { return }
            completion(entityArray)
        })
    }
    func makeObjectRequest<U: Decodable>(completion: @escaping (U) -> Void) {
        self.observeSingleEvent(of: .value, with: { snapshot in
            guard let object = snapshot.value as? [String: Any] else { return }
            guard let entity: U = unbox(from: object) else { return }
            completion(entity)
        })
    }
}
