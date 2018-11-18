//
//  Async.swift
//  bitcorewallet
//
//  Created by Adrian Corscadden on 2017-03-02.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import Foundation

enum Async {
    static func parallel(callbacks: [(@escaping () -> Void) -> Void], completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        callbacks.forEach { cb in
            dispatchGroup.enter()
            cb({
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: .main) { 
            completion()
        }
    }
}
