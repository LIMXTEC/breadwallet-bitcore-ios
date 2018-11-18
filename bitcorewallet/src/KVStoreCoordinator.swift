//
//  KVStoreCoordinator.swift
//  bitcorewallet
//
//  Created by Adrian Corscadden on 2017-03-12.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import Foundation

class KVStoreCoordinator : Subscriber {

    init(kvStore: BRReplicatedKVStore) {
        self.kvStore = kvStore
    }

    func retreiveStoredWalletInfo() {
        guard !hasRetreivedInitialWalletInfo else { return }
        if let walletInfo = WalletInfo(kvStore: kvStore) {
            Store.perform(action: WalletChange(Currencies.btx).setWalletName(walletInfo.name))
            Store.perform(action: WalletChange(Currencies.btx).setWalletCreationDate(walletInfo.creationDate))
        } else {
            print("no wallet info found")
        }
        hasRetreivedInitialWalletInfo = true
    }

    func listenForWalletChanges() {
        Store.subscribe(self,
                            selector: { $0[Currencies.btx].creationDate != $1[Currencies.btx].creationDate },
                            callback: {
                                if let existingInfo = WalletInfo(kvStore: self.kvStore) {
                                    Store.perform(action: WalletChange(Currencies.btx).setWalletCreationDate(existingInfo.creationDate))
                                } else {
                                    let newInfo = WalletInfo(name: $0[Currencies.btx].name)
                                    newInfo.creationDate = $0[Currencies.btx].creationDate
                                    self.set(newInfo)
                                }
        })
    }

    private func set(_ info: BRKVStoreObject) {
        do {
            let _ = try kvStore.set(info)
        } catch let error {
            print("error setting wallet info: \(error)")
        }
    }

    private let kvStore: BRReplicatedKVStore
    private var hasRetreivedInitialWalletInfo = false
}
