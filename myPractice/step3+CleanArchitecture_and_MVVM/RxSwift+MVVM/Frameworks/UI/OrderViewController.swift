//
//  OrderViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxViewController

class OrderViewController: UIViewController {
    // MARK: - Life Cycle
    var viewModel: IOrderViewModel!
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: update selected menu info
        updateTextViewHeight()
    }

    // MARK: - UI Logic

    func updateTextViewHeight() {
        let text = ordersList.text ?? ""
        let width = ordersList.bounds.width
        let font = ordersList.font ?? UIFont.systemFont(ofSize: 20)

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        let height = boundingBox.height

        ordersListHeight.constant = height + 40
    }
    
    // MARK: - Interface Builder

    @IBOutlet weak var ordersList: UITextView!
    @IBOutlet weak var ordersListHeight: NSLayoutConstraint!
    @IBOutlet weak var itemsPrice: UILabel!
    @IBOutlet weak var vatPrice: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
}

extension OrderViewController {
    
    func setupBindings(completion: (() -> Void)? = nil) {
        
        //output
        rx.viewWillAppear
             .map { _ in () }
             .bind(to: viewModel.viewWillAppear)
             .disposed(by: disposeBag)
        
        //input
        viewModel.orderedItemsText
            .bind(to:ordersList.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.totalPrice
            .bind(to:itemsPrice.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.totalVatPrice
            .bind(to:vatPrice.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.finalPrice
            .bind(to:totalPrice.rx.text)
            .disposed(by: disposeBag)
    }
}
