//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController

class MenuViewController: UIViewController {
    // MARK: - InterfaceBuilder Links

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    var viewModel: MenuViewModel = MenuViewModel()
    private var disposeBag = DisposeBag()
}

extension MenuViewController {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl()
        setupBindings()
    }
    
    func setupBindings() {
        
        // output
        rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .map{ _ in () }
            .bind(to: viewModel.didRequestToRefresh)
            .disposed(by: disposeBag)
            
        clearButton.rx.tap
            .bind(to: viewModel.didSelectClear)
            .disposed(by: disposeBag)
        
        orderButton.rx.tap
            .bind(to: viewModel.didSelectOrder)
            .disposed(by: disposeBag)

        // input
        viewModel.loading
            .distinctUntilChanged()
            .subscribe(onNext: {[weak self] in
                if $0 {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.tableView.refreshControl?.endRefreshing()
                }
                self?.activityIndicator.isHidden = !$0
            })
            .disposed(by: disposeBag)
        
        viewModel.totalCount
            .bind(to: itemCountLabel.rx.text)
            .disposed(by: disposeBag)
            
        viewModel.totalPrice
            .bind(to: totalPrice.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.menuItems
            .bind(to: tableView.rx.items(cellIdentifier: "MenuItemTableViewCell", cellType: MenuItemTableViewCell.self)) {[weak self](row, item, cell) in
                guard let self = self else { return }
                cell.data.onNext(item)
                cell.onPlus
                    .subscribe(onNext: {
                        self.viewModel.didSelectIncrease.onNext(row)
                    })
                    .disposed(by: cell.disposeBag)
                cell.onMinus
                    .subscribe(onNext: {
                        self.viewModel.didSelectDecrease.onNext(row)
                    })
                    .disposed(by: cell.disposeBag)

            }.disposed(by: disposeBag)
        
        viewModel.showOrderView
            .subscribe(onNext: showOrderView)
            .disposed(by: disposeBag)
        
        viewModel.orderfailAlert
            .subscribe(onNext: {[weak self] alert in
                self?.showAlert(title: alert.title, message: alert.message)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func showOrderView(_ order: Order?) {
        if let order = order, let viewController = storyboard?.instantiateViewController(withIdentifier: "OrderViewController")
            as? OrderViewController {
            let interactor = OrderInteractor()
            let viewModel = OrderViewModel()
            viewModel.inputBoundary = interactor
            interactor.outputBoundary = viewModel
            interactor.order = order
            viewController.viewModel = viewModel
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }

}
