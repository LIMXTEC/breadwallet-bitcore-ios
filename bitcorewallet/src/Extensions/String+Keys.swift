//
//  String+Keys.swift
//  bitcorewallet
//
//  Created by Adrian Corscadden on 2017-06-14.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import Foundation
import BRCore

extension String {
    var isValidPrivateKey: Bool {
        return BRPrivKeyIsValid(self) != 0
    }

    var isValidBip38Key: Bool {
        return BRBIP38KeyIsValid(self) != 0
    }
}
