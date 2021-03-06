//
//  AppDelegate.swift
//  newsGuess
//
//  Created by Никита Максаковский on 25.11.2019.
//  Copyright © 2019 Никита Максаковский. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let userDataUrl = "https://codeforces.com/api/user.info?handles="
    private let contestsUrl = "https://codeforces.com/api/contest.list?gym=false"
    private let ratingChange = "https://codeforces.com/api/user.rating?handle="
    private let handles = [Constants.emptyString]
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(userDataUrl, forKey: "userDataUrl")
        UserDefaults.standard.set(contestsUrl, forKey: "contestsUrl")
        UserDefaults.standard.set(ratingChange, forKey: "ratingChange")
        
        guard let tmpHandles = UserDefaults.standard.object(forKey: "handles") as? [String] else {
            UserDefaults.standard.set(handles, forKey: "handles")
            return true
        }
        UserDefaults.standard.set(tmpHandles, forKey: "handles")
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    
}

