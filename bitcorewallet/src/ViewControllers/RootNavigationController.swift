//
//  RootNavigationController.swift
//  bitcorewallet
//
//  Created by Adrian Corscadden on 2017-12-05.
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import UIKit

class RootNavigationController : UINavigationController {

    var walletManager: WalletManager? {
        didSet {
            guard let walletManager = walletManager else { return }
            if !walletManager.noWallet && Store.state.isLoginRequired {
                let loginView = LoginViewController(isPresentedForLock: false, walletManager: walletManager)
                loginView.transitioningDelegate = loginTransitionDelegate
                loginView.modalPresentationStyle = .overFullScreen
                loginView.modalPresentationCapturesStatusBarAppearance = true
                loginView.shouldSelfDismiss = true
                present(loginView, animated: false, completion: {
                    self.tempLoginView.remove()
                    //todo - attempt show welcome here
//                    self.attemptShowWelcomeView(loginView: loginView)
                })
            }
        }
    }

    private var tempLoginView = LoginViewController(isPresentedForLock: false)
    private let welcomeTransitingDelegate = PinTransitioningDelegate()
    private let loginTransitionDelegate = LoginTransitionDelegate()

    override func viewDidLoad() {
        self.addChildViewController(tempLoginView, layout: {
            tempLoginView.view.constrain(toSuperviewEdges: nil)
        })
        guardProtected(queue: DispatchQueue.main) {
            if WalletManager.staticNoWallet {
                self.tempLoginView.remove()
                let tempStartView = StartViewController(didTapCreate: {}, didTapRecover: {})
                self.addChildViewController(tempStartView, layout: {
                    tempStartView.view.constrain(toSuperviewEdges: nil)
                    tempStartView.view.isUserInteractionEnabled = false
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    tempStartView.remove()
                })
            }
        }
        self.delegate = self
    }


    private func attemptShowWelcomeView(loginView: UIViewController) {
        if !UserDefaults.hasShownWelcome {
            let welcome = WelcomeViewController()
            welcome.transitioningDelegate = welcomeTransitingDelegate
            welcome.modalPresentationStyle = .overFullScreen
            welcome.modalPresentationCapturesStatusBarAppearance = true
            welcomeTransitingDelegate.shouldShowMaskView = false
            loginView.present(welcome, animated: true, completion: nil)
            UserDefaults.hasShownWelcome = true
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if topViewController is HomeScreenViewController {
            return .default
        } else {
            return .lightContent
        }
    }
}

extension RootNavigationController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is HomeScreenViewController {
            UserDefaults.selectedCurrencyCode = nil
        } else if let accountView = viewController as? AccountViewController {
            UserDefaults.selectedCurrencyCode = accountView.currency.code
            UserDefaults.mostRecentSelectedCurrencyCode = accountView.currency.code
        }
    }
}
