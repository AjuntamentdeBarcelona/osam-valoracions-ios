//
//  ViewController.swift
//  Test_Swift
//
//  Created by Antonio García on 25/01/2019.
//  Copyright © 2019 OpenRoad. All rights reserved.
//

import UIKit
import AppStoreRatings

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update AppStoreRatings status
        let url = URL(string: "https://www.openroad.es/projects/appstoreratings/test/ratings_config.json")!
        AppStoreRatings.shared.updateRatingStats(configURL: url) { result in
            switch result {
            case .success(let isDialogRequested):
                NSLog("Finished: isDialogRequested: \(isDialogRequested)")
                
            case .failure(let error):
                NSLog("error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        // Debug internal status
        #if DEBUG
        NSLog("status: \(AppStoreRatings.shared.currentStatusDescription())")
        
        NSLog("Library internal status:");
        AppStoreRatings.shared.debugCurrentStatus(configURL: url) { result in
            switch result {
            
            case let .success(willRequestDialog, launchCountsRemaining, daysRemaining, wasPreviouslyRequested):
                NSLog("willRequestDialog: \(willRequestDialog)")
                NSLog("wasPreviouslyRequested: \(wasPreviouslyRequested)")
                NSLog("launchCountsRemaining: \(launchCountsRemaining)")
                NSLog("daysRemaining: \(String(format: "%.3f", daysRemaining))")

            case .failure(let error):
                NSLog("error: \(error.localizedDescription)")
            }
        }
        #endif
    }


}

