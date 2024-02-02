// BillManager

import Foundation
import UserNotifications

struct Bill: Codable {
    let id: UUID
    var amount: Double?
    var dueDate: Date?
    var paidDate: Date?
    var payee: String?
    var remindDate: Date?
    var notificationID: String?
    
    init(id: UUID = UUID()) {
        self.id = id
    }
}

extension Bill: Hashable {
//    static func ==(_ lhs: Bill, _ rhs: Bill) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
}

extension Bill {
    
    static let notificationCategoryID = "billNotification"
    static let remindInHourID = "remind In Hour"
    static let markAsPaidID = "Mark As Paid"
    
    mutating func scheduleReminder(dateScheduled: Date, completion: @escaping (Bill) -> ()) {
        
        removeReminder()
        
        let notificationID = UUID().uuidString
        
        var updatedBill = self
        updatedBill.notificationID = notificationID
        updatedBill.remindDate = dateScheduled
        checkNotificationAuthorization { granted in
            guard granted else {
                DispatchQueue.main.async {
                    completion(updatedBill)
                }
                
                return
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Bill Reminder"
        content.body = "\(updatedBill.amount!) due on \(updatedBill.formattedDueDate)"
        content.categoryIdentifier = Bill.notificationCategoryID
        
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dateScheduled)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: updatedBill.notificationID!, content: content, trigger: trigger)
        
        
        UNUserNotificationCenter.current().add(request) { (error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    print("\(error.localizedDescription)")
                    completion(updatedBill)
                } else {
                    completion(updatedBill)
                }
            }
        }
    }
    
    mutating func removeReminder() {
        if let notificationID = notificationID {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
            self.notificationID = nil
            self.remindDate = nil
        }
    }
    
    func checkNotificationAuthorization(completion: @escaping (Bool) -> ()) {
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true)
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, _) in
                    completion(granted)
                })
            case .denied:
                completion(false)
            case .ephemeral:
                completion(false)
            case .provisional:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }
}
