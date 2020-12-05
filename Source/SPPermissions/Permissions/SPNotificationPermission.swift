// The MIT License (MIT)
// Copyright © 2019 Ivan Varabei (varabeis@icloud.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if SPPERMISSION_NOTIFICATION

import UIKit
import UserNotifications

struct SPNotificationPermission: SPPermissionProtocol {
    
    var type: SPNotificationType
    
    enum SPNotificationType {
        case Notifications
        #if os(iOS)
        case NotificationsAndCriticalAlerts
        case CriticalAlerts
        #endif
    }
    
    init(type: SPNotificationType) {
        self.type = type
    }
    
    var isAuthorized: Bool {
        guard let authorizationSetting = fetchAuthorizationStatus() else { return false }
        switch (type) {
        case .Notifications:
            return authorizationSetting.authorizationStatus == .authorized
        case .NotificationsAndCriticalAlerts:
            if #available(iOS 12.0, *) {
                return authorizationSetting.authorizationStatus == .authorized && authorizationSetting.criticalAlertSetting == .enabled
            } else {
                return authorizationSetting.authorizationStatus == .authorized
            }
        case .CriticalAlerts:
            if #available(iOS 12.0, *) {
                return authorizationSetting.criticalAlertSetting == .enabled
            } else {
                return false
            }
        }
    }
    
    var isDenied: Bool {
        guard let authorizationSetting = fetchAuthorizationStatus() else { return false }
        switch (type) {
        case .Notifications:
            return authorizationSetting.authorizationStatus == .denied
        case .NotificationsAndCriticalAlerts:
            if #available(iOS 12.0, *) {
                return authorizationSetting.authorizationStatus == .denied || authorizationSetting.criticalAlertSetting == .disabled
            } else {
                return authorizationSetting.authorizationStatus == .denied
            }
        case .CriticalAlerts:
            if #available(iOS 12.0, *) {
                return authorizationSetting.criticalAlertSetting == .disabled
            } else {
                return false
            }
        }
    }
    private func fetchAuthorizationStatus() -> UNNotificationSettings? {
        var notificationSettings: UNNotificationSettings?
        let semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global().async {
            UNUserNotificationCenter.current().getNotificationSettings { setttings in
                notificationSettings = setttings
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return notificationSettings
    }
    
    func request(completion: @escaping ()->()?) {
        if #available(iOS 10.0, tvOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            var opt : UNAuthorizationOptions = [.badge, .alert, .sound]
            if #available(iOS 12.0, *) {
                opt.insert(.providesAppNotificationSettings)
                if (type == .NotificationsAndCriticalAlerts || type == .CriticalAlerts) {
                    opt.insert(.criticalAlert)
                }
            }
            center.requestAuthorization(options:opt) { (granted, error) in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else { // iOS9
            #if os(iOS)
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            #endif
            DispatchQueue.main.async {
                completion()
            }
        }
        
        UIApplication.shared.registerForRemoteNotifications()
    }
}

#endif
