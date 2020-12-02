//
//  NotificationHandler.swift
//  Oasis
//
//  Created by Greeley Lindberg on 6/13/20.
//  Copyright © 2020 Lindberg Parlan. All rights reserved.
//
import Foundation
import UserNotifications

class NotificationHandler {
    
    let center = UNUserNotificationCenter.current()
    
    func requestPermission() {
        // Request notification authorizations at first launch
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Notifications granted")
            }
            else {
                print ("Notifications declined")
            }
        }
    }
    
    func setReminder(title: String, body: String, hour: Int, minute: Int) {
        // Configure notification
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.sound = UNNotificationSound.default     // could be fun to have a custom sound later on
        
        // Configure the trigger a certain time
        var dateInfo = DateComponents()
        dateInfo.hour = hour
        dateInfo.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
         
        // Request
        let request = UNNotificationRequest(identifier: "Daily Reminder", content: content, trigger: trigger)
        center.add(request) {(error) in
            // check error parameter here
            if error != nil{
                print("Something went wrong --> \(String(describing: error))")
            }
            print ("Alarm Notification scheduled")
        }
    }
    func setReminder(title: String, body: String, timeInterval: Int) {
        // Configure notification
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: body, arguments: nil)
        content.sound = UNNotificationSound.default     // could be fun to have a custom sound later on
        
        // Configure the trigger a certain time
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: true)
         
        // Request
        let request = UNNotificationRequest(identifier: "Timed Reminder", content: content, trigger: trigger)
        center.add(request) {(error) in
            // check error parameter here
            if error != nil{
                print("Something went wrong --> \(String(describing: error))")
            }
            print ("Timed Notification scheduled")
        }
    }
}
