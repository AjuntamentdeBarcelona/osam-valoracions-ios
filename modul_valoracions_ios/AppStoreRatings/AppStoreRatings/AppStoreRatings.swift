//
//  AppStoreRatings.swift
//  AppStoreRatings
//
//  Created by Antonio García (antonio@openroad.es) on 21/01/2019.
//  Copyright © 2019 Ajuntament de Barcelona
//

import Foundation
import StoreKit

@objc public class AppStoreRatings: NSObject {
    // Singleton
    @objc public static let shared = AppStoreRatings()

    // MARK: - Actions
    
    /**
     Ask the user to rate or review the app if the config file conditions are met.
     This method should be called ONCE per app launch. Each time is called increments the internal number of launches.

     - Parameter configURL: url to the json file with the configuration parameters.
     - Parameter completion: returns a Result<Bool>. If successful the returned boolean is true if the config conditions were met and the store dialog was requested to StoreKit. (To avoid common mistakes the completion block is executed on the main thread)
     
     Example JSON configuration file:
     {
        "tmin" : 0,
        "num_apert" : 1
     }
     
     "tmin" is the minimum number of days since the first app launch to request the review dialog
     "num_apert" is the minimum number of app launches needed to request the review dialog

     The review dialog will only be displayed one time for each app build version number (CFBundleVersion)
     
     Note: This method may not show the review dialog even if the condition are met if the StoreKit limits don't allow the dialog to be displayed (max 3 dialogs within a 365-day period)
     */
    public func updateRatingStats(configURL url: URL, completion: ((Result<Bool>) -> ())? = nil) {
        guard !PersistentData().wasPreviouslyRequested else {
            // The dialog was previously shown, so skip any test and return
            completion?(.success(false))
            return
        }
        
        config(fromURL: url) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let config):
                    let isDialogShown = self.updateRatingStats(config: config)
                    completion?(.success(isDialogShown))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        }
    }
    
    /**
     Refer to: updateRatingStats(configURL url: URL, completion: @escaping (Result<Bool>) -> ())
     Method provided for Objective-C compatiblity
     */
    @objc public func updateRatingStats(configUrl url: URL, completion: ((_ isDialogRequested: Bool, _ error: Error?) -> ())?) {
        updateRatingStats(configURL: url) { result in
            switch result {
            case .success(let isDialogRequested):
                completion?(isDialogRequested, nil)
                
            case .failure(let error):
                completion?(false, error)
            }
        }
    }
    
    /**
     Returns a simple description with the current status (including current launch count, first launch date and if the review dialog has been already displayed for the current app build)
    */
    @objc public func currentStatusDescription() -> String {
        let data = PersistentData()
        let firstLaunchDate = Date(timeIntervalSince1970: data.firstLaunchTimestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return "launchCount: \(data.currentLaunchCount), firstLaunch: \(dateFormatter.string(for: firstLaunchDate) ?? "-"), wasPreviouslyRequested: \(data.wasPreviouslyRequested)"
    }

    /**
     Useful to debug when the configuration conditions are met
     - Parameter configURL: url to the json file with the configuration parameters.
     - Parameter completion: returns a Result<isDialogRequested, launchCountsRemaining, daysRemaining, wasPreviouslyRequested>.
     
     - Parameter willRequestDialog: true if the conditions are met and calling updateRatingStats will request the review dialog
     - Parameter launchCountsRemaining: number of app launches remaining
     - Parameter daysRemaining: number of days remaining
     - Parameter wasPreviouslyRequested: true if the review dialog was previously requested (it will never be requested again for the current app build)
     */

    public func debugCurrentStatus(configURL url: URL, completion: @escaping (Result<(willRequestDialog: Bool, launchCountsRemaining: Int, daysRemaining: Double, wasPreviouslyRequested: Bool)>) -> ()) {
        config(fromURL: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let config):
                    let data = PersistentData()
                    let launchCountsRemaining = max(0, config.minLaunches - data.currentLaunchCount)
                    let currentTimestamp = Date().timeIntervalSince1970
                    let kDaysToSeconds = 24 * 60 * 60
                    let askRatingTimetamp = data.firstLaunchTimestamp + TimeInterval(config.minDays * kDaysToSeconds)      // First launch + number of days to wait
                    let daysRemaining = max(0, (askRatingTimetamp - currentTimestamp) / Double(kDaysToSeconds))
                    let willRequestDialog = !data.wasPreviouslyRequested && data.currentLaunchCount > config.minLaunches && currentTimestamp >= data.firstLaunchTimestamp + askRatingTimetamp
                    
                    completion(.success((willRequestDialog, launchCountsRemaining, daysRemaining, data.wasPreviouslyRequested)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    
    /**
     Refer to: func debugCurrentStatus(configURL url: URL, completion: @escaping (Result<(willRequestDialog: Bool, launchCountsRemaining: Int, daysRemaining: Double, wasPreviouslyRequested: Bool)>) -> ())
     Method provided for Objective-C compatiblity
     */
    @objc public func debugCurrentStatus(configURL url: URL, completion: @escaping (_ willRequestDialog: Bool, _ launchCountsRemaining: Int, _ daysRemaining: Double, _ wasPreviouslyRequested: Bool, _ error: Error?) -> ()) {
        
        debugCurrentStatus(configURL: url) { result in
            switch result {
            case let .success(willRequestDialog, launchCountsRemaining, daysRemaining, wasPreviouslyRequested):
                completion(willRequestDialog, launchCountsRemaining, daysRemaining, wasPreviouslyRequested, nil)
                
            case .failure(let error):
                completion(false, -1, -1, false, error)
            }
        }        
    }
    
    private func updateRatingStats(config: ConfigData) -> Bool {
        return updateRatingStats(minLaunchCount: config.minLaunches, minDays: config.minDays)
    }
    
    private func updateRatingStats(minLaunchCount: Int, minDays: Int) -> Bool {
        var isDialogRequested = false
        
        // Increment launch counter
        var data = PersistentData()
        data.currentLaunchCount = data.currentLaunchCount + 1
        
        if !data.wasPreviouslyRequested && data.currentLaunchCount >= minLaunchCount {
            let currentTimestamp = Date().timeIntervalSince1970
            let kDaysToSeconds = 24 * 60 * 60
            let askRatingTimestamp = data.firstLaunchTimestamp + TimeInterval(minDays * kDaysToSeconds)      // First launch + number of days to wait
            if currentTimestamp >= askRatingTimestamp {
                showRatingDialog()
                data.wasPreviouslyRequested = true
                isDialogRequested = true
            }
        }
        
        data.persistData()
        return isDialogRequested
    }
    
    private func showRatingDialog() {
        SKStoreReviewController.requestReview()
    }
    
    // MARK:- Config JSON format
    private struct ConfigData: Decodable {
        var minLaunches: Int                    // Minimum number app openings to show the rate prompt
        var minDays: Int                        // Minimum number of days from the first app opening to show the rate prompt
    
        private enum CodingKeys: String, CodingKey {
            case minLaunches = "num_apert", minDays = "tmin"/*, title, messages*/
        }
    }
    
    // MARK: - Parse config file
    private func config(fromURL url: URL, completion: @escaping (Result<ConfigData>) -> ()) {
        data(fromURL: url) { result in
            switch result {
            case .success(let data):
                do {
                    let config = try JSONDecoder().decode(ConfigData.self, from: data)
                    completion(.success(config))
                }
                catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - File download
    private func data(fromURL url: URL, completion: @escaping (Result<Data>) -> ()) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(.failure(error ?? NetworkError.emptyDataError()))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    enum NetworkError: Error {
        case emptyDataError()
    }

    // MARK: - Persist Data
    private struct PersistentData {
        // Config
        private static let kPersistenDataKeyPrefix = "appstoreratings_persistentdata_"
        private static let kCurrentLaunchCountKey = "launch_count"
        private static let kLaunchFirstTimeDateKey = "launch_firsttime_date"
        private static let kWasPreviouslyRequestedKey = "was_previously_requested"

        // Data
        var currentLaunchCount: Int
        var firstLaunchTimestamp: TimeInterval
        var wasPreviouslyRequested: Bool
        private let persistDataKey: String

        // Lifecycle
        init() {
            // Generate a data key depending on the app build number so it is reset for each new app build
            let appVersionBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
            persistDataKey = PersistentData.kPersistenDataKeyPrefix+appVersionBuild

            // Cache data from userDefaults
            let data = UserDefaults.standard.dictionary(forKey: persistDataKey) ?? [:]
            currentLaunchCount = data[PersistentData.kCurrentLaunchCountKey] as? Int ?? 0
            firstLaunchTimestamp = data[PersistentData.kLaunchFirstTimeDateKey] as? TimeInterval ?? Date().timeIntervalSince1970
            wasPreviouslyRequested = data[PersistentData.kWasPreviouslyRequestedKey] as? Bool ?? false
        }

        // Actions
        func persistData() {
            // Save data to UserDefaults
            let data: [String: Any] = [
                PersistentData.kCurrentLaunchCountKey: currentLaunchCount,
                PersistentData.kLaunchFirstTimeDateKey: firstLaunchTimestamp,
                PersistentData.kWasPreviouslyRequestedKey: wasPreviouslyRequested,
            ]
            UserDefaults.standard.setValue(data, forKey: persistDataKey)
        }
    }
    
    // MARK: - Result Type
    public enum Result<Value> {
        case success(Value)
        case failure(Error)
        
        var isSuccess: Bool {
            switch self {
            case .success:
                return true
            case .failure:
                return false
            }
        }
    }
}
