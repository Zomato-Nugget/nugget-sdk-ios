//
//  ViewController.swift
//  NuggetSDKExample
//
//  Created by Rajesh Budhiraja on 05/06/25.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func openNugget(_ sender: Any) {
        let deeplink = "nugget://unified-support/conversation?flowType=ticketing&omniTicketingFlow=true"
        openNugget(with: deeplink)
    }

    /// Builds the Nugget chat screen for `deeplink` and pushes it onto the navigation stack.
    ///
    /// Called both by the in-app button and by `AppDelegate` when a Nugget push is tapped.
    @objc func openNugget(with deeplink: String) {
        guard let vc = NuggetService.getNuggetVC(deeplink: deeplink) else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
}
