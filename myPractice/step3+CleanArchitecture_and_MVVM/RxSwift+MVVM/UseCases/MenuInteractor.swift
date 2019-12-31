//
//  MenuInteractor.swift
//  RxSwift+MVVM
//
//  Created by mine on 2019/12/26.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

protocol MenuInputBoundary: class {
    var outputBoundary: MenuOutputBoundary! {get set}
    func fetchMenuInformation()
    func orderItems()
    func increaseItemCount(_ itemIndex: Int)
    func decreaseItemCount(_ itemIndex: Int)
    func clearAllSelections()
}

protocol MenuOutputBoundary: class {
    func reloadMenu(_ menu: Menu)
    func reloadMenu(_ menu: Menu, indices: [Int])
    func showOrderView(_ order: Order)
    func showOrderFailAlert()
    func showErrorAlert(_ error: Error)
}

class MenuInteractor: MenuInputBoundary {
    
    weak var outputBoundary: MenuOutputBoundary!
    private var menu = Menu()
    private var disposeBag = DisposeBag()
    
    func fetchMenuInformation() {
        APIService.fetchAllMenus()
            .observeOn(MainScheduler.instance)
            .do(onError: {[weak self] in
                self?.outputBoundary.showErrorAlert($0)
            })
            .subscribe(onNext: {[weak self] in
               guard let self = self else { return }
                    self.menu.setMenuItems($0)
                    self.outputBoundary.reloadMenu(self.menu)

            })
            .disposed(by: disposeBag)
    }
    
    func orderItems() {
        if menu.selectedMenuItems.isEmpty {
            outputBoundary.showOrderFailAlert()
        } else {
            let orderedItems = menu.selectedMenuItems.map { Order.MenuItem(name: $0.name, price: $0.price, count: $0.count)
            }
            outputBoundary.showOrderView(Order(orderedItems: orderedItems))
        }
    }
    
    func increaseItemCount(_ itemIndex: Int) {
        menu.increaseCount(at: itemIndex)
        outputBoundary.reloadMenu(menu, indices: [itemIndex])
    }
    
    func decreaseItemCount(_ itemIndex: Int) {
        menu.decreaseCount(at: itemIndex)
        outputBoundary.reloadMenu(menu)
    }
    
    func clearAllSelections() {
        menu.clear()
        outputBoundary.reloadMenu(menu)
    }
}
