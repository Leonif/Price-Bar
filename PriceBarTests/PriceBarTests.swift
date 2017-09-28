//
//  PriceBarTests.swift
//  PriceBarTests
//
//  Created by Leonid Nifantyev on 8/27/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import XCTest
@testable import PriceBar

class PriceBarTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}


//MARK: Categories
extension PriceBarTests {
    
    func testCategories() {
        
        let deviceBase = CoreDataService.data
        
        let item = ShopItem(id: "111", name: "Test product", quantity: 1, minPrice: 0, price: 0, itemCategory: ItemCategory(id: 111, name: "TestCategory"), itemUom: ItemUom(id: 111,name: "TestUom",iterator: 0.1), outletId: "Test", scanned: true, checked: false)
        
        deviceBase.saveToShopList(item)
        
        
        
        let itemCategories = deviceBase.getCategoriesFromCoreData()
        
        
         XCTAssertEqual(itemCategories.count, 13, "Category list is \(itemCategories.count) items")
    }
    
    func testPickerCategoriesCount() {
        
        
        
        
    }
    
}
