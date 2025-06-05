//
//  ViewController.swift
//  NuggetSDKExample
//
//  Created by Rajesh Budhiraja on 05/06/25.
//

import UIKit

class ViewController: UIViewController {
    
    private let nuggetService = NuggetService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func openNugget(_ sender: Any) {
        guard let vc = nuggetService.getNuggetVC(deeplink: "dummy://unified-support/conversation?flowType=ticketing&omniTicketingFlow=true") else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

