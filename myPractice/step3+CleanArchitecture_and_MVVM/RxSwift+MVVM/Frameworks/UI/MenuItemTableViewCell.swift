//
//  MenuItemTableViewCell.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
//import RxCocoa

class MenuItemTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    private(set) var data = BehaviorSubject<MenuViewModel.MenuItem>(value: MenuViewModel.MenuItem(name: "", price: "0", count: "0"))
    private(set) var onPlus = PublishSubject<Void>()
    private(set) var onMinus = PublishSubject<Void>()
    private(set) var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBindings()
    }
    
    private func setupBindings() {
        
        // input
        data.map{ $0.name }
            .bind(to: title.rx.text)
            .disposed(by: disposeBag)
        data.map{ $0.count }
            .bind(to: count.rx.text)
            .disposed(by: disposeBag)
        data.map{ $0.price }
            .bind(to: price.rx.text)
            .disposed(by: disposeBag)
        
        // output
        plusButton.rx.tap
            .bind(to: onPlus)
            .disposed(by: disposeBag)
        minusButton.rx.tap
            .bind(to: onMinus)
            .disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        setupBindings()
    }
}
