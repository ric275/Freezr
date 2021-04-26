//
//  AppDelegate.swift
//  Freezr
//
//  Created by Jack Taylor on 09/10/2016.
//  Copyright © 2016-2018 Jack Taylor. All rights reserved.
//
//  Meow meow meow meow 🐱
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //let newPurple:UIColor = UIColor(red: 125/255.0, green: 80/255.0, blue: 230/255.0, alpha: 1.0)
        let newPurple2:UIColor = UIColor(red: 146/255.0, green: 54/255.0, blue: 240/255.0, alpha: 1.0)

        
        //Get rid of back arrow and delete the extra space.
        
        UINavigationBar.appearance().backIndicatorImage = UIImage()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage()
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset.init(horizontal: 0, vertical: 0), for: UIBarMetrics.default)
        
        //Make everything purple.
        //Purple is bae.
        
        UINavigationBar.appearance().tintColor = newPurple2
        
        UITabBar.appearance().tintColor = newPurple2
        
        UITableViewCell.appearance().tintColor = newPurple2
        
        //Set up notification request.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in
            //Handle the error if there is one - empty for now.
        })
        
        //Set up inital userDefaults
        
        let userDefaultsDefaults = [
            "freezerSwitchOn" : true,
            "fridgeSwitchOn" : true,
            "preFreqNeverTicked" : false,
            "preFreq2WeekTicked" : true,
            "preFreq1WeekTicked" : true,
            "preFreq2DayTicked" : true
        ]

        UserDefaults.standard.register(defaults: userDefaultsDefaults)

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
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
        let container = NSPersistentContainer(name: "Freezr")
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
    
    //3D Touch shortcuts.
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        //Shopping List shortcut.
        
        if shortcutItem.type == "Jack-Taylor.Freezr.shopping-list" {
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            
            let shoppingListVC = sb.instantiateViewController(withIdentifier: "Tab Bar Controller") as! UITabBarController
            shoppingListVC.selectedIndex = 2
            
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            
            rootVC?.present(shoppingListVC, animated: false, completion: nil)
        }
    }
    
    //Set up orientations.
    
    var shouldSupportAllOrientation = false
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if (shouldSupportAllOrientation == true){
            return UIInterfaceOrientationMask.all
        }
        return UIInterfaceOrientationMask.portrait
    }
}

//Set up date comparisons (magic).

extension NSDate {
    
    func isGreaterThanDate(dateToCompare : Date) -> Bool {
        
        var isGreater = false
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending
        { isGreater = true }
        return isGreater
    }
    
    func isLessThanDate(dateToCompare : Date) -> Bool {
        
        var isLess = false
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedAscending
        { isLess = true }
        return isLess
    }
    
    //Probably don't need this - but it's useful to have for future.
    
    func addDays(daysToAdd : Int) -> NSDate {
        
        let secondsInDays : TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.addingTimeInterval(secondsInDays)
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd : Int) -> NSDate {
        
        let secondsInHours : TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = self.addingTimeInterval(secondsInHours)
        return dateWithHoursAdded
    }
}

