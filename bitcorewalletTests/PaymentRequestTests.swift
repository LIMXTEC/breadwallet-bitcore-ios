//
//  PaymentRequestTests.swift
//  bitcorewallet
//
//  Created by Adrian Corscadden on 2017-03-26.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import XCTest
@testable import breadwallet

class PaymentRequestTests : XCTestCase {

    func testEmptyString() {
        XCTAssertNil(PaymentRequest(string: "", currency: Currencies.btx))
        XCTAssertNil(PaymentRequest(string: "", currency: Currencies.bch))
    }

    func testInvalidAddress() {
        XCTAssertNil(PaymentRequest(string: "notandaddress", currency: Currencies.btx), "Payment request should be nil for invalid addresses")
        XCTAssertNil(PaymentRequest(string: "notandaddress", currency: Currencies.bch), "Payment request should be nil for invalid addresses")
    }

    func testBasicExampleBTC() {
        let uri = "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu"
        let request = PaymentRequest(string: uri, currency: Currencies.btx)
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.toAddress == "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertTrue(request?.displayAddress == "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
    }
    
    func testBasicExampleBCH() {
        let uri = "bitcoincash:qr2g8fyjy0csdujuxcg02syrp5eaqgtn9ytlk3650u"
        let request = PaymentRequest(string: uri, currency: Currencies.bch)
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.toAddress == "bitcoincash:qr2g8fyjy0csdujuxcg02syrp5eaqgtn9ytlk3650u".bitcoinAddr)
        XCTAssertTrue(request?.displayAddress == "bitcoincash:qr2g8fyjy0csdujuxcg02syrp5eaqgtn9ytlk3650u")
    }

    func testAmountInUriBTC() {
        let uri = "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=1.2"
        let request = PaymentRequest(string: uri, currency: Currencies.btx)
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.toAddress == "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertTrue(request?.displayAddress == "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertTrue(request?.amount?.rawValue == 120000000)
    }
    
    func testAmountInUriBCH() {
        let uri = "bitcoincash:qr2g8fyjy0csdujuxcg02syrp5eaqgtn9ytlk3650u?amount=1.2"
        let request = PaymentRequest(string: uri, currency: Currencies.bch)
        XCTAssertNotNil(request)
        XCTAssertTrue(request?.toAddress == "bitcoincash:qr2g8fyjy0csdujuxcg02syrp5eaqgtn9ytlk3650u".bitcoinAddr)
        XCTAssertTrue(request?.displayAddress == "bitcoincash:qr2g8fyjy0csdujuxcg02syrp5eaqgtn9ytlk3650u")
        XCTAssertTrue(request?.amount?.rawValue == 120000000)
    }

    func testRequestMetaDataBTC() {
        let uri = "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=1.2&message=Payment&label=Satoshi"
        let request = PaymentRequest(string: uri, currency: Currencies.btx)
        XCTAssertTrue(request?.toAddress == "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertTrue(request?.displayAddress == "12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu")
        XCTAssertTrue(request?.amount?.rawValue == 120000000)
        XCTAssertTrue(request?.message == "Payment")
        XCTAssertTrue(request?.label == "Satoshi")
    }
    
    func testRequestMetaDataBCH() {
        let uri = "bitcoincash:qr2g8fyjy0csdujuxcg02syrp5eaqgtn9ytlk3650u?amount=1.2&message=Payment&label=Satoshi"
        let request = PaymentRequest(string: uri, currency: Currencies.bch)
        XCTAssertTrue(request?.toAddress == "bitcoincash:qr2g8fyjy0csdujuxcg02syrp5eaqgtn9ytlk3650u".bitcoinAddr)
        XCTAssertTrue(request?.displayAddress == "bitcoincash:qr2g8fyjy0csdujuxcg02syrp5eaqgtn9ytlk3650u")
        XCTAssertTrue(request?.amount?.rawValue == 120000000)
        XCTAssertTrue(request?.message == "Payment")
        XCTAssertTrue(request?.label == "Satoshi")
    }

    func testExtraEqualSign() {
        let uri = "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=1.2&message=Payment=true&label=Satoshi"
        let request = PaymentRequest(string: uri, currency: Currencies.btx)
        XCTAssertTrue(request?.message == "Payment=true")
    }

    func testMessageWithSpace() {
        let uri = "bitcoin:12A1MyfXbW6RhdRAZEqofac5jCQQjwEPBu?amount=1.2&message=Payment message test&label=Satoshi"
        let request = PaymentRequest(string: uri, currency: Currencies.btx)
        XCTAssertTrue(request?.message == "Payment message test")
    }

    func testPaymentProtocol() {
        let uri = "https://www.syndicoin.co/signednoroot.paymentrequest"
        let request = PaymentRequest(string: uri, currency: Currencies.btx)
        XCTAssertTrue(request?.type == .remote)

        let promise = expectation(description: "Fetch Request")
        request?.fetchRemoteRequest(completion: { newRequest in
            XCTAssertNotNil(newRequest)
            promise.fulfill()
        })

        waitForExpectations(timeout: 5.0) { error in
            XCTAssertNil(error)
        }
    }
}
