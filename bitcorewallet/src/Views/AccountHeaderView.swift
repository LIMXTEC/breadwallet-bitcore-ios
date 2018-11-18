//
//  AccountHeaderView.swift
//  bitcorewallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import UIKit

private let largeFontSize: CGFloat = 28.0
private let smallFontSize: CGFloat = 14.0

class AccountHeaderView : UIView, GradientDrawable, Subscriber {

    // MARK: - Views
    
    private let currencyName = UILabel(font: .customBody(size: 18.0))
    private let exchangeRateLabel = UILabel(font: .customBody(size: 14.0))
    private let balanceLabel = UILabel(font: .customBody(size: 14.0))
    private let primaryBalance: UpdatingLabel
    private let secondaryBalance: UpdatingLabel
    private let conversionSymbol = UIImageView(image: #imageLiteral(resourceName: "conversion"))
    private let currencyTapView = UIView()
    private let syncIndicator = SyncingIndicator(style: .account)
    private let modeLabel = UILabel(font: .customBody(size: 12.0), color: .transparentWhiteText) // debug info
    
    private var regularConstraints: [NSLayoutConstraint] = []
    private var swappedConstraints: [NSLayoutConstraint] = []
    
    // MARK: Properties
    private let currency: CurrencyDef
    private var hasInitialized = false
    private var hasSetup = false
    
    private var isSyncIndicatorVisible: Bool = false {
        didSet {
            UIView.crossfade(balanceLabel, syncIndicator, toRight: isSyncIndicatorVisible, duration: 0.3)
        }
    }

    var isWatchOnly: Bool = false {
        didSet {
            if E.isTestnet || isWatchOnly {
                if E.isTestnet && isWatchOnly {
                    modeLabel.text = "(Testnet - Watch Only)"
                } else if E.isTestnet {
                    modeLabel.text = "(Testnet)"
                } else if isWatchOnly {
                    modeLabel.text = "(Watch Only)"
                }
                modeLabel.isHidden = false
            }
            if E.isScreenshots {
                modeLabel.isHidden = true
            }
        }
    }
    private var exchangeRate: Rate? {
        didSet {
            DispatchQueue.main.async {
                self.setBalances()
            }
        }
    }
    
    private var balance: UInt64 = 0 {
        didSet {
            DispatchQueue.main.async {
                self.setBalances()
            }
        }
    }
    
    private var isBtcSwapped: Bool {
        didSet {
            DispatchQueue.main.async {
                self.setBalances()
            }
        }
    }

    // MARK: -
    
    init(currency: CurrencyDef) {
        
        self.currency = currency
        self.isBtcSwapped = Store.state.isSwapped
        if let rate = currency.state.currentRate {
            let maxDigits = currency.state.maxDigits
            let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: maxDigits, currency: currency)
            self.exchangeRate = rate
            self.secondaryBalance = UpdatingLabel(formatter: placeholderAmount.localFormat)
            self.primaryBalance = UpdatingLabel(formatter: placeholderAmount.btxFormat)
        } else {
            self.secondaryBalance = UpdatingLabel(formatter: NumberFormatter())
            self.primaryBalance = UpdatingLabel(formatter: NumberFormatter())
        }
        super.init(frame: CGRect())
        
        setup()
    }

    // MARK: Private
    
    private func setup() {
        addSubviews()
        addConstraints()
        addShadow()
        setData()
        addSubscriptions()
    }

    private func setData() {
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        currencyName.textColor = .white
        currencyName.textAlignment = .center
        currencyName.text = currency.name
        
        exchangeRateLabel.textColor = .transparentWhiteText
        exchangeRateLabel.textAlignment = .center
        
        balanceLabel.textColor = .transparentWhiteText
        balanceLabel.text = S.Account.balance
        conversionSymbol.tintColor = .whiteTint
        
        primaryBalance.textAlignment = .right
        secondaryBalance.textAlignment = .right
        
        swapLabels()

        modeLabel.isHidden = true
        syncIndicator.isHidden = true
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(currencySwitchTapped))
        currencyTapView.addGestureRecognizer(gr)
    }

    private func addSubviews() {
        addSubview(currencyName)
        addSubview(exchangeRateLabel)
        addSubview(balanceLabel)
        addSubview(primaryBalance)
        addSubview(secondaryBalance)
        addSubview(conversionSymbol)
        addSubview(modeLabel)
        addSubview(syncIndicator)
        addSubview(currencyTapView)
    }

    private func addConstraints() {
        currencyName.constrain([
            currencyName.constraint(.leading, toView: self, constant: C.padding[2]),
            currencyName.constraint(.trailing, toView: self, constant: -C.padding[2]),
            currencyName.constraint(.top, toView: self, constant: E.isIPhoneX ? C.padding[5] : C.padding[3])
            ])
        
        exchangeRateLabel.pinTo(viewAbove: currencyName)
        
        balanceLabel.constrain([
            balanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]),
            balanceLabel.bottomAnchor.constraint(equalTo: primaryBalance.topAnchor, constant: 0.0)
            ])
        
        primaryBalance.constrain([
            primaryBalance.firstBaselineAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[2])
            ])
        
        secondaryBalance.constrain([
            secondaryBalance.firstBaselineAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[2]),
            ])
        
        conversionSymbol.constrain([
            conversionSymbol.heightAnchor.constraint(equalToConstant: 12.0),
            conversionSymbol.heightAnchor.constraint(equalTo: conversionSymbol.widthAnchor),
            conversionSymbol.bottomAnchor.constraint(equalTo: primaryBalance.firstBaselineAnchor)
            ])
        
        currencyTapView.constrain([
            currencyTapView.trailingAnchor.constraint(equalTo: balanceLabel.trailingAnchor),
            currencyTapView.topAnchor.constraint(equalTo: primaryBalance.topAnchor, constant: -C.padding[1]),
            currencyTapView.bottomAnchor.constraint(equalTo: primaryBalance.bottomAnchor, constant: C.padding[1]) ])

        regularConstraints = [
            primaryBalance.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]),
            primaryBalance.leadingAnchor.constraint(equalTo: conversionSymbol.trailingAnchor, constant: C.padding[1]),
            conversionSymbol.leadingAnchor.constraint(equalTo: secondaryBalance.trailingAnchor, constant: C.padding[1]),
            currencyTapView.leadingAnchor.constraint(equalTo: secondaryBalance.leadingAnchor)
        ]

        swappedConstraints = [
            secondaryBalance.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]),
            secondaryBalance.leadingAnchor.constraint(equalTo: conversionSymbol.trailingAnchor, constant: C.padding[1]),
            conversionSymbol.leadingAnchor.constraint(equalTo: primaryBalance.trailingAnchor, constant: C.padding[1]),
            currencyTapView.leadingAnchor.constraint(equalTo: primaryBalance.leadingAnchor)
        ]

        NSLayoutConstraint.activate(isBtcSwapped ? self.swappedConstraints : self.regularConstraints)

        modeLabel.constrain([
            modeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
            modeLabel.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor)
            ])
        
        syncIndicator.constrain([
            syncIndicator.trailingAnchor.constraint(equalTo: balanceLabel.trailingAnchor),
            syncIndicator.topAnchor.constraint(equalTo: balanceLabel.topAnchor),
            syncIndicator.bottomAnchor.constraint(equalTo: balanceLabel.bottomAnchor)
            ])
    }

    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 8.0
    }

    private func addSubscriptions() {
        Store.lazySubscribe(self,
                            selector: { $0.isSwapped != $1.isSwapped },
                            callback: { self.isBtcSwapped = $0.isSwapped })
        Store.lazySubscribe(self,
                            selector: { $0[self.currency].currentRate != $1[self.currency].currentRate},
                            callback: {
                                if let rate = $0[self.currency].currentRate {
                                    let maxDigits = $0[self.currency].maxDigits
                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: maxDigits, currency: self.currency)
                                    self.secondaryBalance.formatter = placeholderAmount.localFormat
                                    self.primaryBalance.formatter = placeholderAmount.btxFormat
                                }
                                self.exchangeRate = $0[self.currency].currentRate
        })
        
        Store.lazySubscribe(self,
                            selector: { $0[self.currency].maxDigits != $1[self.currency].maxDigits},
                            callback: {
                                if let rate = $0[self.currency].currentRate {
                                    let maxDigits = $0[self.currency].maxDigits
                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: maxDigits, currency: self.currency)
                                    self.secondaryBalance.formatter = placeholderAmount.localFormat
                                    self.primaryBalance.formatter = placeholderAmount.btxFormat
                                    self.setBalances()
                                }
        })
        Store.subscribe(self,
                        selector: {$0[self.currency].balance != $1[self.currency].balance },
                        callback: { state in
                            if let balance = state[self.currency].balance {
                                self.balance = balance
                            } })
        
        Store.subscribe(self, selector: { $0[self.currency].syncState != $1[self.currency].syncState },
                        callback: { state in
                            switch state[self.currency].syncState {
                            case .connecting:
                                self.isSyncIndicatorVisible = true
                                self.syncIndicator.text = S.SyncingView.connecting
                            case .syncing:
                                self.isSyncIndicatorVisible = true
                                self.syncIndicator.text = S.SyncingView.syncing
                            case .success:
                                self.isSyncIndicatorVisible = false
                            }
        })
        
        Store.subscribe(self, selector: {
            return $0[self.currency].lastBlockTimestamp != $1[self.currency].lastBlockTimestamp },
                        callback: { state in
                            self.syncIndicator.progress = CGFloat(state[self.currency].syncProgress)
        })
    }

    func setBalances() {
        guard let rate = exchangeRate else { return }
        
        exchangeRateLabel.text = "\(rate.localString)\(S.AccountHeader.exchangeRateSeparator)\(currency.code)"
        
        let maxDigits = currency.state.maxDigits
        let amount = Amount(amount: balance, rate: rate, maxDigits: maxDigits, currency: currency)
        
        if !hasInitialized {
            primaryBalance.setValue(amount.amountForRvnFormat)
            secondaryBalance.setValue(amount.localAmount)
            swapLabels()
            hasInitialized = true
        } else {
            if primaryBalance.isHidden {
                primaryBalance.isHidden = false
            }

            if secondaryBalance.isHidden {
                secondaryBalance.isHidden = false
            }
            
            primaryBalance.setValueAnimated(amount.amountForRvnFormat, completion: { [weak self] in
                self?.swapLabels()
            })
            secondaryBalance.setValueAnimated(amount.localAmount, completion: { [weak self] in
                self?.swapLabels()
            })
        }
    }
    
    private func swapLabels() {
        NSLayoutConstraint.deactivate(isBtcSwapped ? regularConstraints : swappedConstraints)
        NSLayoutConstraint.activate(isBtcSwapped ? swappedConstraints : regularConstraints)
        if isBtcSwapped {
            primaryBalance.makeSecondary()
            secondaryBalance.makePrimary()
        } else {
            primaryBalance.makePrimary()
            secondaryBalance.makeSecondary()
        }
    }

    override func draw(_ rect: CGRect) {
        drawGradient(start: currency.colors.0, end: currency.colors.1, rect)
    }

    @objc private func currencySwitchTapped() {
        layoutIfNeeded()
        UIView.spring(0.7, animations: {
            self.primaryBalance.toggle()
            self.secondaryBalance.toggle()
            NSLayoutConstraint.deactivate(!self.isBtcSwapped ? self.regularConstraints : self.swappedConstraints)
            NSLayoutConstraint.activate(!self.isBtcSwapped ? self.swappedConstraints : self.regularConstraints)
            self.layoutIfNeeded()
        }) { _ in }

        Store.perform(action: CurrencyChange.toggle())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -

private extension UILabel {
    func makePrimary() {
        font = UIFont.customBold(size: largeFontSize)
        textColor = .white
        reset()
    }
    
    func makeSecondary() {
        font = UIFont.customBody(size: largeFontSize)
        textColor = .transparentWhiteText
        shrink()
    }
    
    func shrink() {
        transform = .identity // must reset the view's transform before we calculate the next transform
        let scaleFactor: CGFloat = smallFontSize/largeFontSize
        let deltaX = frame.width * (1-scaleFactor)
        let deltaY = frame.height * (1-scaleFactor)
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        transform = scale.translatedBy(x: deltaX, y: deltaY/2.0)
    }
    
    func reset() {
        transform = .identity
    }
    
    func toggle() {
        if transform.isIdentity {
            makeSecondary()
        } else {
            makePrimary()
        }
    }
}
