//
//  AppDelegate.swift
//  BillManager
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let forNotificationID = response.notification.request.identifier
        
        let bill = Database.shared.getBills(forNotificationID)
        
        if var bill = bill {
            switch response.actionIdentifier {
            case Bill.remindInHourID:
                let remindDate = Date().addingTimeInterval(3600)
                bill.scheduleReminder(dateScheduled: remindDate) { updateBill in
                    Database.shared.updateAndSave(updateBill)
                    completionHandler()
                }
            case Bill.markAsPaidID:
                bill.paidDate = Date()
                Database.shared.updateAndSave(bill)
                completionHandler()
            default:
                break
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let center = UNUserNotificationCenter.current()
        
        center.delegate = self
        
        let remindInHourAction = UNNotificationAction(identifier: Bill.remindInHourID, title: "Remind In An Hour", options: [], icon: UNNotificationActionIcon(systemImageName: "clock"))
        
        let markBillAsPaidAction = UNNotificationAction(identifier: Bill.markAsPaidID, title: "Mark As Paid", options: [.authenticationRequired], icon: UNNotificationActionIcon(systemImageName: "dollarsign.circle"))
        
        let billCategory = UNNotificationCategory(identifier: Bill.notificationCategoryID, actions: [remindInHourAction, markBillAsPaidAction], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([billCategory])
        
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

