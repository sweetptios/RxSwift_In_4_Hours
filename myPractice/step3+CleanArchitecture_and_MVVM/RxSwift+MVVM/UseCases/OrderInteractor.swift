//
//  OrderInteractor.swift
//  RxSwift+MVVM
//
//  Created by mine on 2019/12/26.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import Foundation

protocol OrderInputBoundary: class {
    var order: Order! { get set }
    var outputBoundary: OrderOutputBoundary! {get set}
    func fetchOrderInformation()
}

protocol OrderOutputBoundary: class {
    func reloadOrder(_ order: Order)
}

class OrderInteractor: OrderInputBoundary {
    var order: Order!
    weak var outputBoundary: OrderOutputBoundary!

    func fetchOrderInformation() {
        outputBoundary.reloadOrder(order)
    }
}
