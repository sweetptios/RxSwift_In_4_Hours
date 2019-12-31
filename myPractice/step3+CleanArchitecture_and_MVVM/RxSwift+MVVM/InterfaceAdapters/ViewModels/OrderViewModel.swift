//
//  OrderViewModel.swift
//  RxSwift+MVVM
//
//  Created by mine on 2019/12/27.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

protocol IOrderViewModel {
    //MARK: - input
    var viewWillAppear: AnyObserver<Void> { get }
    //MARK: - output
    var orderedItemsText: Observable<String> { get }
    var totalVatPrice: Observable<String> { get }
    var totalPrice: Observable<String> { get }
    var finalPrice: Observable<String> { get }
}

class OrderViewModel {
    
    var inputBoundary: OrderInputBoundary!
 
    private let _viewWillAppear = PublishSubject<Void>()
    private let _orderedItemsText = BehaviorSubject<String>(value: "")
    private let _totalVatPrice = BehaviorSubject<String>(value: 0.currencyKR())
    private let _totalPrice = BehaviorSubject<String>(value: 0.currencyKR())
    private let _finalPrice = BehaviorSubject<String>(value: 0.currencyKR())
    
    private var disposeBag = DisposeBag()
    
    init() { setupBindings() }
    
    private func setupBindings() {
        
        _viewWillAppear
            .subscribe(onNext: {[weak self] _ in
                self?.inputBoundary.fetchOrderInformation()
            })
            .disposed(by: disposeBag)
    }
}

extension OrderViewModel: IOrderViewModel {
     var viewWillAppear: AnyObserver<Void> { _viewWillAppear.asObserver() }
     var orderedItemsText: Observable<String> { _orderedItemsText.asObservable() }
     var totalVatPrice: Observable<String> { _totalVatPrice.asObservable() }
     var totalPrice: Observable<String> { _totalPrice.asObservable() }
     var finalPrice: Observable<String> { _finalPrice.asObservable() }
}

extension OrderViewModel: OrderOutputBoundary {
    
    func reloadOrder(_ order: Order) {
        _orderedItemsText.onNext(order.orderedItems.map{ "\($0.name), \($0.count), \($0.price.currencyKR())\n"}.reduce("",+))
        _totalPrice.onNext(order.totalPrice.currencyKR())
        _totalVatPrice.onNext(order.totalVatPrice.currencyKR())
        _finalPrice.onNext(order.finalPrice.currencyKR())
    }
}
