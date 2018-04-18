//
//  AppDelegate.swift
//  MesFactures
//
//  Created by Sébastien on 01/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import Buglife
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //TODO: - Add crashLytics
        Fabric.with([Crashlytics.self])
        
        // realm migration configuration
//        let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { (migration: Migration, oldSchemaVersion: UInt64) in
//            if oldSchemaVersion < 2 {
//                migration.enumerateObjects(ofType: "", { (oldObject: MigrationObject?, newObject: MigrationObject?) in
//                    
//                })
//            }
//        })
//        Realm.Configuration.defaultConfiguration = config
        
//        Buglife.shared().start(withAPIKey: "H9aZT1n1CeWjSu0B7r9IWQtt")
        Buglife.shared().start(withEmail: "myfacturesapp@gmail.com")
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        if let database = DbManager().getDb() {
            database.initYear()
            database.initCategory()
            database.updateApplicationData()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        self.window?.rootViewController?.dismiss(animated: false, completion: {
            if self.window != nil {
                self.window!.rootViewController = rootController
            }
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

