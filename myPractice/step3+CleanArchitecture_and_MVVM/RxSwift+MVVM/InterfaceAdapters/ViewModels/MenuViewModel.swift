//
//  MenuViewModel.swift
//  RxSwift+MVVM
//
//  Created by mine on 2019/12/27.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

protocol IMenuViewModel {
    associatedtype MenuItem
    //MARK: - input
    var viewWillAppear: AnyObserver<Void> { get }
    var didRequestToRefresh: AnyObserver<Void> { get }
    var didSelectClear: AnyObserver<Void> { get }
    var didSelectOrder: AnyObserver<Void> { get }
    var didSelectIncrease: AnyObserver<Int> { get }
    var didSelectDecrease: AnyObserver<Int> { get }
    //MARK: - output
    var loading: Observable<Bool> { get }
    var menuItems: Observable<[MenuItem]> { get }
    var totalCount: Observable<String> { get }
    var totalPrice: Observable<String> { get }
    var orderfailAlert: Observable<(title: String, message: String)> { get }
    var showOrderView: Observable<Order> { get }
}

class MenuViewModel {

    struct MenuItem {
        let name: String
        let price: String
        let count: String
    }
    
    lazy var inputBoundary: MenuInputBoundary! = {
        let interactor = MenuInteractor()
        interactor.outputBoundary = self
        return interactor
    }()
    
    private let _viewWillAppear = PublishSubject<Void>()
    private let _didRequestToRefresh = PublishSubject<Void>()
    private let _didSelectClear = PublishSubject<Void>()
    private let _didSelectOrder = PublishSubject<Void>()
    private let _didSelectIncrease = PublishSubject<Int>()
    private let _didSelectDecrease = PublishSubject<Int>()
    private let _loading = BehaviorSubject<Bool>(value: false)
    private let _menuItems = BehaviorSubject<[MenuItem]>(value: [])
    private let _totalCount = BehaviorSubject<String>(value: String(0))
    private let _totalPrice = BehaviorSubject<String>(value:0.currencyKR())
    private let _orderfailAlert = PublishSubject<(title: String, message: String)>()
    private let _showOrderView = PublishSubject<Order>()
    
    private var disposeBag = DisposeBag()
    
    init() { setupBindings() }
    
    private func setupBindings() {
        
        let firstLoad = _viewWillAppear.take(1)
        Observable.merge([firstLoad, _didRequestToRefresh])
            .subscribe(onNext: {[weak self] _ in
                self?._loading.onNext(true)
                self?.inputBoundary.fetchMenuInformation()
            })
            .disposed(by: disposeBag)
        
        Observable.merge([_viewWillAppear, _didSelectClear])
            .subscribe({[weak self] _ in
                self?.inputBoundary.clearAllSelections()
            })
            .disposed(by: disposeBag)
        
        _didSelectOrder
            .subscribe(onNext: {[weak self] _ in
                self?.inputBoundary.orderItems()
            })
            .disposed(by: disposeBag)
        
        _didSelectIncrease
            .subscribe(onNext: {[weak self] in
                self?.inputBoundary.increaseItemCount($0)
            })
            .disposed(by: disposeBag)
        
        _didSelectDecrease
            .subscribe(onNext: {[weak self] in
                self?.inputBoundary.decreaseItemCount($0)
            })
            .disposed(by: disposeBag)
    }
}

extension MenuViewModel: IMenuViewModel {
    var viewWillAppear: AnyObserver<Void> { _viewWillAppear.asObserver() }
    var didRequestToRefresh: AnyObserver<Void> { _didRequestToRefresh.asObserver() }
    var didSelectClear: AnyObserver<Void> { _didSelectClear.asObserver() }
    var didSelectOrder: AnyObserver<Void> { _didSelectOrder.asObserver() }
    var didSelectIncrease: AnyObserver<Int> { _didSelectIncrease.asObserver() }
    var didSelectDecrease: AnyObserver<Int> { _didSelectDecrease.asObserver() }
    var loading: Observable<Bool> { _loading.asObservable() }
    var menuItems: Observable<[MenuViewModel.MenuItem]> { _menuItems.asObservable() }
    var totalCount: Observable<String> { _totalCount.asObservable() }
    var totalPrice: Observable<String> { _totalPrice.asObservable() }
    var orderfailAlert: Observable<(title: String, message: String)> { _orderfailAlert.asObservable() }
    var showOrderView: Observable<Order> { _showOrderView.asObservable() }
}

extension MenuViewModel: MenuOutputBoundary {
    
    func reloadMenu(_ menu: Menu) {
        _loading.onNext(false)
        fillViewModel(from: menu)
    }
    
    func reloadMenu(_ menu: Menu, indices: [Int]) {
        _loading.onNext(false)
        fillViewModel(from: menu)
    }
    
    func showOrderView(_ order: Order) {
        _showOrderView.onNext(order)
    }
    
    func showOrderFailAlert() {
        _orderfailAlert.onNext(("Order Fail", "No Orders"))
    }
    
    func showErrorAlert(_ error: Error) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [weak self]_ in
            self?._loading.onNext(false)
        }
        _orderfailAlert.onNext(("Fail", error.localizedDescription))
            
    }
    
    private func fillViewModel(from menu: Menu) {
        let menuItems = menu.menuItems.map { MenuViewModel.MenuItem(name: $0.name, price: $0.price.currencyKR(), count: "\($0.count)")}
        self._menuItems.onNext(menuItems)
        _totalCount.onNext("\(menu.totalCount)")
        _totalPrice.onNext(menu.totalPrice.currencyKR())
    }
}

