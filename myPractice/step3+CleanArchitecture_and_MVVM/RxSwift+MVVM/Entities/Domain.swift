//
//  Model.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import Foundation

struct Menu {
    
    struct MenuItem {
        private(set) var name: String
        private(set) var price: Int
        private(set) var count: Int
        init(name: String, price: Int, count: Int) {
            self.name = name
            self.price = price
            self.count = max(0, count)
        }
    }
    
    private(set) var menuItems = [MenuItem]()
    var itemCount: Int { menuItems.count }
    var totalCount: Int { menuItems.map{ $0.count }.reduce(0, +) }
    var totalPrice: Int { menuItems.map{ $0.count * $0.price }.reduce(0, +) }
    var selectedMenuItems: [MenuItem] { menuItems.filter { $0.count > 0 } }
    
    mutating func setMenuItems(_ items: [MenuItem]) {
        self.menuItems = items
    }
    
    subscript(_ index: Int) -> MenuItem? {
        return menuItems[index]
    }
    
    mutating func clear() {
        menuItems = menuItems.map{ MenuItem(name: $0.name, price: $0.price, count: 0)}
    }
    
    mutating func increaseCount(at itemIndex: Int) {
        menuItems = changeCount(at: itemIndex, offset: 1)
    }
    
    mutating func decreaseCount(at itemIndex: Int) {
        menuItems = changeCount(at: itemIndex, offset: -1)
    }
    
    private func changeCount(at itemIndex: Int, offset: Int) -> [MenuItem] {
        menuItems.enumerated().map { (arg) -> Menu.MenuItem in
            let (i, item) = arg
            return (i == itemIndex ? MenuItem(name: item.name, price: item.price, count: item.count + offset) : item)
        }
    }
}

struct Order {
    
    struct MenuItem {
        let name: String
        let price: Int
        let count: Int
    }
    
    private(set) var orderedItems = [MenuItem]()
    
    var totalVatPrice: Int { (Int(Float( calculateTotalPrice()) * 0.1 / 10 + 0.5) * 10) }
    var totalPrice: Int { calculateTotalPrice() }
    var finalPrice: Int { totalPrice + totalVatPrice }

    private func calculateTotalPrice() -> Int {
        orderedItems.reduce(0) { $0 + $1.count * $1.price }
    }
}
