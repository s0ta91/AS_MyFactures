//
//  AppDelegate.swift
//  MesFactures
//
//  Created by Sébastien on 01/02/2018.
//  Copyright © 2018 Sébastien Constant. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import IQKeyboardManagerSwift
import Buglife
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let APP_VERSION = "MyAppVersion"
    
    static var persistentContainer: NSPersistentContainer {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    }

    // MARK: - Launching treatment
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

//        print("didFinishLaunchingWithOptions")
        
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
        print("[REALM] - \(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
        
        //TODO:  Set UserDefaults initialisation values
        Manager.setIsFirstLoad(true)
        UserDefaults.standard.set(false, forKey: UserDefaults.keys.savedApplicationState.rawValue)
        UserDefaults.standard.set(false, forKey: UserDefaults.keys.fromOtherApp.rawValue)
        
        // TODO: buglife configuration
        Buglife.shared().start(withEmail: Settings().emailAdress)
        
        // TODO: IQKeyboardManager configuration
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        // TODO: try to create the database
        guard let database = DbManager().getDb() else { fatalError("No database found") }
        
        // TODO: Initialize all default data in coreData database
        database.initYear()
        database.initCategory()
        database.updateApplicationData()
        
        if let realmDb = DbManager().getRealmDb() {
            database._realm = realmDb
            
            // TODO: Initialize all data from Realm
            database.initRealmData()
            
            // TODO: Migrate data from Realm to CoreData
            database.migrateToCoreData()
        }
        
        
        // TODO: Check if password is already set ELSE show createAccount screen instead of login screen
        if database.hasMasterPassword() == false {
            displayCreateAccountVC(withPassword: false)
        } else if UserDefaults.standard.string(forKey: UserDefaults.keys.userEmail.rawValue) == nil {
            // FIXME: Obsolete. To Delete
            //            database.getFromUserDefault(forKey: "USER_EMAIL") == nil {
            
            displayCreateAccountVC(withPassword: true)
        }
        
        return true
    }

    //MARK: - Restauration states functions
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
//        print("Should save data")
        coder.encode(Settings().APP_VERSION_NUMBER, forKey: APP_VERSION)
        UserDefaults.standard.set(true, forKey: UserDefaults.keys.savedApplicationState.rawValue)
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {

        let version = coder.decodeObject(forKey: APP_VERSION) as! String

        // Restore the state only if the app version matches.
        if version == Settings().APP_VERSION_NUMBER {
//            print("Should restore data")
            return true
        }

        // Do not restore from old data.
        return false
    }
    

    // MARK: - Other functions
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//        print("Will resign active")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
//        print("WillEnterForground")
        displayLoginScreen(application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        print("did become active")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        print("Arrive from an other app")
        UserDefaults.standard.set(true, forKey: UserDefaults.keys.fromOtherApp.rawValue)
        UserDefaults.standard.set(url, forKey: UserDefaults.keys.fileFromOtherAppUrl.rawValue)
//        print("URL: \(url)")
        return true
    }
    
    
    
    // MARK: - Private
    // TODO: Display the create account VC
    private func displayCreateAccountVC (withPassword: Bool) {
        let storyboard = UIStoryboard(name: "CreateAccountViewController", bundle: nil)
        let createAccountVC = storyboard.instantiateViewController(withIdentifier: "CreateAccountVC") as! CreateAccountViewController
        createAccountVC.isPasswordSet = withPassword
        window?.rootViewController = createAccountVC
    }
    
    private func displayLoginScreen(_ application: UIApplication) {
        guard let topMostVC = application.topMostViewController(),
            let topMostVCName = topMostVC.classForCoder.description().components(separatedBy: ".").last else {
                fatalError("Unknown topMostVC")
        }
        if topMostVCName != "VerifyPasswordViewController" && topMostVCName != "CreateAccountViewController" && topMostVCName != "LoginViewController" {
            Manager.presentLoginScreen(fromViewController: topMostVC)
        }
    }

}

