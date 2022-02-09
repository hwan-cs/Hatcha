//
//  LocalNotificationManager.swift
//  Hatcha
//
//  Created by Jung Hwan Park on 2022/01/30.
//

import Foundation
import UserNotifications

struct Notification
{
    var destination: String
    var title: String
    var body: String
}

class LocalNotificationManager
{
    var notifications = [Notification]()

    func listScheduledNotifications()
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests
        { notifications in

            for notification in notifications
            {
                print(notification)
            }
        }
    }

    private func requestAuthorization()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        { granted, error in
            if granted == true && error == nil
            {
                self.scheduleNotifications()
            }
        }
    }

    func schedule()
    {
        UNUserNotificationCenter.current().getNotificationSettings
        { settings in

            switch settings.authorizationStatus
            {
                case .notDetermined:
                    self.requestAuthorization()
                case .authorized, .provisional:
                    self.scheduleNotifications()
                default:
                    break // Do nothing
            }
        }
    }

    private func scheduleNotifications()
    {
        for notification in notifications
        {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = .default

            let request = UNNotificationRequest(identifier: notification.destination, content: content, trigger: nil)

            UNUserNotificationCenter.current().add(request)
            { error in

                guard error == nil else { return }
                
                print("Notification scheduled! --- ID = \(notification.destination)")
            }
        }
    }

}
