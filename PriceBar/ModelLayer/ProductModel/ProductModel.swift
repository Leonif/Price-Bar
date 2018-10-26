//
//  DataProvider.swift
//  Price Bar
//
//  Created by Leonid Nifantyev on 6/4/17.
//  Copyright © 2017 LionLife. All rights reserved.
//

import Foundation
import UIKit

protocol ProductModel {
    func getProductDetail(productId: String, outletId: String,
                          completion: @escaping (ResultType<ShoplistViewItem, ProductModelError>) -> Void)
    func getCountry(for productId: String, completion: @escaping (String?) -> Void)

    func getProductInfoList(for ids: [String], completion: @escaping (([String: ProductEntity]) -> Void))

    func getQuantityOfProducts(completion: @escaping (ResultType<Int, ProductModelError>) -> Void)
    func getItem(with barcode: String, callback: @escaping (ProductEntity?) -> Void)

    func getPriceList(for ids: [String], and outletId: String, completion: @escaping ([String: Double]) -> Void)
    func getPrice(for productId: String, and outletId: String, completion: @escaping (Double) -> Void)
    func savePrice(for productId: String, statistic: PriceStatisticViewItem)

    func getProductEntity(for productId: String,
                          completion: @escaping (ResultType<ProductEntity, ProductModelError>) -> Void)
    func save(new product: ProductEntity)
    func getParametredUom(for uomId: Int32, completion: @escaping (UomEntity) -> Void)

    func getCategoryId(for categoryName: String, completion: @escaping (ResultType<Int?, ProductModelError>) -> Void)
    func getCategoryName(for categoryId: Int32, completion: @escaping (ResultType<String, ProductModelError>) -> Void)
    func getCategoryList(completion: @escaping (ResultType<[CategoryEntity], ProductModelError>) -> Void)

    func getUomId(for uomName: String, completion: @escaping (ResultType<Int?, ProductModelError>) -> Void)
    func getUomName(for uomId: Int32, completion: @escaping (ResultType<String, ProductModelError>) -> Void)
    func getUomList(completion: @escaping (ResultType<[UomViewItem]?, ProductModelError>) -> Void)
}
