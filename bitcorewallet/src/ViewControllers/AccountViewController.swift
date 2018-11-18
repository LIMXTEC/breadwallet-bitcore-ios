//
//  AccountViewController.swift
//  bitcorewallet
//
//  Created by Adrian Corscadden on 2016-11-16.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import UIKit
import BRCore
import MachO

let accountHeaderHeight: CGFloat = 152.0
let accountFooterHeight: CGFloat = 67.0

class AccountViewController : UIViewController, Subscriber {

    //MARK: - Public
    let currency: CurrencyDef
    
    init(walletManager: WalletManager) {
        self.walletManager = walletManager
        self.currency = walletManager.currency
        self.headerView = AccountHeaderView(currency: currency)
        self.footerView = AccountFooterView(currency: currency)
        super.init(nibName: nil, bundle: nil)
        self.transactionsTableView = TransactionsTableViewController(walletManager: walletManager, didSelectTransaction: didSelectTransaction)
        
        headerView.isWatchOnly = walletManager.isWatchOnly
        footerView.sendCallback     = { Store.perform(action: RootModalActions.Present(modal: .send(currency: walletManager.currency))) }
        footerView.receiveCallback  = { Store.perform(action: RootModalActions.Present(modal: .receive(currency: walletManager.currency))) }
    }

    //MARK: - Private
    private let walletManager: WalletManager
    private let headerView: AccountHeaderView
    private let footerView: AccountFooterView
    private let transitionDelegate = ModalTransitionDelegate(type: .transactionDetail)
    private var transactionsTableView: TransactionsTableViewController!
    private var isLoginRequired = false
    private let searchHeaderview: SearchHeaderView = {
        let view = SearchHeaderView()
        view.isHidden = true
        return view
    }()
    private let headerContainer = UIView()
    private var loadingTimer: Timer?
    private var shouldShowStatusBar: Bool = true {
        didSet {
            if oldValue != shouldShowStatusBar {
                UIView.animate(withDuration: C.animationDuration) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // detect jailbreak so we can throw up an idiot warning, in viewDidLoad so it can't easily be swizzled out
        if !E.isSimulator {
            var s = stat()
            var isJailbroken = (stat("/bin/sh", &s) == 0) ? true : false
            for i in 0..<_dyld_image_count() {
                guard !isJailbroken else { break }
                // some anti-jailbreak detection tools re-sandbox apps, so do a secondary check for any MobileSubstrate dyld images
                if strstr(_dyld_get_image_name(i), "MobileSubstrate") != nil {
                    isJailbroken = true
                }
            }
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { note in
                self.showJailbreakWarnings(isJailbroken: isJailbroken)
            }
            showJailbreakWarnings(isJailbroken: isJailbroken)
        }

        setupNavigationBar()
        addTransactionsView()
        addSubviews()
        addConstraints()
        addSubscriptions()
        setInitialData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldShowStatusBar = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        headerView.setBalances()
        if walletManager.peerManager?.connectionStatus == BRPeerStatusDisconnected {
            DispatchQueue.walletQueue.async { [weak self] in
                self?.walletManager.peerManager?.connect()
            }
        }
    }
    
    // MARK: -
    
    private func setupNavigationBar() {
        let searchButton = UIButton(type: .system)
        searchButton.setImage(#imageLiteral(resourceName: "SearchIcon"), for: .normal)
        searchButton.frame = CGRect(x: 0.0, y: 12.0, width: 22.0, height: 22.0) // for iOS 10
        searchButton.widthAnchor.constraint(equalToConstant: 22.0).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        searchButton.tintColor = .white
        searchButton.tap = showSearchHeaderView
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
        
    }

    private func addSubviews() {
        view.addSubview(headerContainer)
        headerContainer.addSubview(headerView)
        headerContainer.addSubview(searchHeaderview)
        view.addSubview(footerView)
    }

    private func addConstraints() {
        headerContainer.constrainTopCorners(height: accountHeaderHeight)
        headerView.constrain(toSuperviewEdges: nil)
        searchHeaderview.constrain(toSuperviewEdges: nil)

        if #available(iOS 11.0, *) {
            footerView.constrain([
                footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                footerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: -C.padding[1]),
                footerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: C.padding[1]),
                footerView.heightAnchor.constraint(equalToConstant: accountFooterHeight)
                ])
        } else {
            footerView.constrain([
                footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -C.padding[1]),
                footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: C.padding[1]),
                footerView.heightAnchor.constraint(equalToConstant: accountFooterHeight)
                ])
        }
    }

    private func addSubscriptions() {
        Store.subscribe(self, selector: { $0.isLoginRequired != $1.isLoginRequired }, callback: { self.isLoginRequired = $0.isLoginRequired })
        Store.subscribe(self, name: .showStatusBar, callback: { _ in
            self.shouldShowStatusBar = true
        })
        Store.subscribe(self, name: .hideStatusBar, callback: { _ in
            self.shouldShowStatusBar = false
        })
    }

    private func setInitialData() {
        searchHeaderview.didCancel = hideSearchHeaderView
        searchHeaderview.didChangeFilters = { [weak self] filters in
            self?.transactionsTableView.filters = filters
        }
    }

    private func addTransactionsView() {
        view.backgroundColor = .whiteTint
        addChildViewController(transactionsTableView, layout: {
            if #available(iOS 11.0, *) {
                transactionsTableView.view.constrain([
                    transactionsTableView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                transactionsTableView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                transactionsTableView.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                transactionsTableView.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                ])
            } else {
                transactionsTableView.view.constrain(toSuperviewEdges: nil)
            }
        })
    }
    
    private func didSelectTransaction(transactions: [Transaction], selectedIndex: Int) -> Void {
        let transactionDetails = TxDetailViewController(transaction: transactions[selectedIndex])
        transactionDetails.modalPresentationStyle = .overCurrentContext
        transactionDetails.transitioningDelegate = transitionDelegate
        transactionDetails.modalPresentationCapturesStatusBarAppearance = true
        present(transactionDetails, animated: true, completion: nil)
    }

    private func showJailbreakWarnings(isJailbroken: Bool) {
        guard isJailbroken else { return }
        let totalSent = walletManager.wallet?.totalSent ?? 0
        let message = totalSent > 0 ? S.JailbreakWarnings.messageWithBalance : S.JailbreakWarnings.messageWithBalance
        let alert = UIAlertController(title: S.JailbreakWarnings.title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: S.JailbreakWarnings.ignore, style: .default, handler: nil))
        if totalSent > 0 {
            alert.addAction(UIAlertAction(title: S.JailbreakWarnings.wipe, style: .default, handler: nil)) //TODO - implement wipe
        } else {
            alert.addAction(UIAlertAction(title: S.JailbreakWarnings.close, style: .default, handler: { _ in
                exit(0)
            }))
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func showSearchHeaderView() {
        let navBarHeight: CGFloat = 44.0
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        var contentInset = self.transactionsTableView.tableView.contentInset
        var contentOffset = self.transactionsTableView.tableView.contentOffset
        contentInset.top += navBarHeight
        contentOffset.y -= navBarHeight
        self.transactionsTableView.tableView.contentInset = contentInset
        self.transactionsTableView.tableView.contentOffset = contentOffset
        UIView.transition(from: self.headerView,
                          to: self.searchHeaderview,
                          duration: C.animationDuration,
                          options: [.transitionFlipFromBottom, .showHideTransitionViews, .curveEaseOut],
                          completion: { _ in
                            self.searchHeaderview.triggerUpdate()
                            self.setNeedsStatusBarAppearanceUpdate()
        })
    }
    
    private func hideSearchHeaderView() {
        let navBarHeight: CGFloat = 44.0
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        var contentInset = self.transactionsTableView.tableView.contentInset
        contentInset.top -= navBarHeight
        self.transactionsTableView.tableView.contentInset = contentInset
        UIView.transition(from: self.searchHeaderview,
                          to: self.headerView,
                          duration: C.animationDuration,
                          options: [.transitionFlipFromTop, .showHideTransitionViews, .curveEaseOut],
                          completion: { _ in
                            self.setNeedsStatusBarAppearanceUpdate()
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return searchHeaderview.isHidden ? .lightContent : .default
    }

    override var prefersStatusBarHidden: Bool {
        return !shouldShowStatusBar
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
