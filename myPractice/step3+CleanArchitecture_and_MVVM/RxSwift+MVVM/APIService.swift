//
//  APIService.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 07/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

let MenuUrl = "https://firebasestorage.googleapis.com/v0/b/rxswiftin4hours.appspot.com/o/fried_menus.json?alt=media&token=42d5cb7e-8ec4-48f9-bf39-3049e796c936"

class APIService {
    
    static func fetchAllMenus() -> Observable<[Menu.MenuItem]> {
        return Observable.create { emitter in
            let task = URLSession.shared.dataTask(with: URL(string: MenuUrl)!) { data, res, err in
    
                struct Response: Decodable {
                    let menus: [MenuItem]
                   
                    struct MenuItem: Decodable {
                       var name: String
                       var price: Int
                   }
                }

                if let err = err {
                    emitter.onError(err)
                    return
                }
                guard let data = data else {
                    let httpResponse = res as! HTTPURLResponse
                    emitter.onError(NSError(domain: "no data",
                    code: httpResponse.statusCode,
                    userInfo: nil))
                    return
                }
                guard let list = try? JSONDecoder().decode(Response.self, from: data) else {
                    emitter.onError(NSError(domain:
                        "Decoding error", code: -1, userInfo: nil))
                    return
                }
                
                emitter.onNext(list.menus.map{ Menu.MenuItem(name: $0.name, price: $0.price, count: 0)})
                emitter.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
