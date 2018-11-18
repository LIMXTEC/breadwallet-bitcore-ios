//
//  AboutViewController.swift
//  bitcorewallet
//
//  Copyright © 2018 Bitcorewallet Team. All rights reserved.
//

import UIKit
import SafariServices

class AboutViewController : UIViewController {

    private let titleLabel = UILabel(font: .customBold(size: 26.0), color: .darkText)
    private var logo: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "LogoGradient"))
        image.contentMode = .scaleAspectFit
        return image
    }()

    private let logoBackground = UIView()
    private let website = AboutCell(text: S.About.website)
    private let twitter = AboutCell(text: S.About.twitter)
    private let reddit = AboutCell(text: S.About.reddit)
    private let privacy = UIButton(type: .system)
    private let footer = UILabel(font: .customBody(size: 13.0), color: .secondaryGrayText)
    override func viewDidLoad() {
        addSubviews()
        addConstraints()
        setData()
        setActions()
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(logoBackground)
        logoBackground.addSubview(logo)
        view.addSubview(website)
        view.addSubview(twitter)
        view.addSubview(reddit)
        view.addSubview(privacy)
        view.addSubview(footer)
    }

    private func addConstraints() {
        titleLabel.constrain([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
            titleLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: C.padding[2]) ])
        logoBackground.constrain([
            logoBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoBackground.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: C.padding[3]),
            logoBackground.heightAnchor.constraint(equalTo: logoBackground.widthAnchor, multiplier: 342.0/553.0)
            ])
        logo.constrain(toSuperviewEdges: nil)
        website.constrain([
            website.topAnchor.constraint(equalTo: logoBackground.bottomAnchor, constant: C.padding[2]),
            website.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            website.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        twitter.constrain([
            twitter.topAnchor.constraint(equalTo: website.bottomAnchor, constant: C.padding[2]),
            twitter.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            twitter.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        reddit.constrain([
            reddit.topAnchor.constraint(equalTo: twitter.bottomAnchor, constant: C.padding[2]),
            reddit.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            reddit.trailingAnchor.constraint(equalTo: view.trailingAnchor) ])
        privacy.constrain([
            privacy.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacy.topAnchor.constraint(equalTo: reddit.bottomAnchor, constant: C.padding[2])])
        footer.constrain([
            footer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footer.topAnchor.constraint(equalTo: privacy.bottomAnchor) ])
    }

    private func setData() {
        view.backgroundColor = .whiteTint
        titleLabel.text = S.About.title
        privacy.setTitle(S.About.privacy, for: .normal)
        privacy.titleLabel?.font = UIFont.customBody(size: 13.0)
        footer.textAlignment = .center
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            footer.text = String(format: S.About.footer, "\(version) (\(build))")
        }
    }

    private func setActions() {
        website.button.tap = strongify(self) { myself in
            myself.presentURL(string: "https://ravencoin.org")
        }
        twitter.button.tap = strongify(self) { myself in
            myself.presentURL(string: "https://twitter.com/ravencoin")
        }
        reddit.button.tap = strongify(self) { myself in
            myself.presentURL(string: "https://reddit.com/r/ravencoin/")
        }
        privacy.tap = strongify(self) { myself in
            myself.presentURL(string: "http://bitcorewallet.org/support/privacy.html")
        }
    }

    private func presentURL(string: String) {
        let vc = SFSafariViewController(url: URL(string: string)!)
        self.present(vc, animated: true, completion: nil)
    }
}
