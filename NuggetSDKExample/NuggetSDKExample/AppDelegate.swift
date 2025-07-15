//
//  AppDelegate.swift
//  NuggetSDKExample
//
//  Created by Rajesh Budhiraja on 05/06/25.
//

import UIKit
import CoreData
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var shouldShowLockScreen: Bool = false
    
    private lazy var appLockView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white // Or any other color/image for your app lock screen
        view.translatesAutoresizingMaskIntoConstraints = false
        // Add any additional UI elements to this view if needed, e.g., a logo or a message
        let label = UILabel()
        label.text = "App Locked"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Request authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Push notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Push notification permission error: \(error.localizedDescription)")
            }
        }
        setupAppLockObservers()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    // MARK: - Push Notification Methods
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        // Save token for later use
        UserDefaults.standard.set(token, forKey: "deviceToken")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    // MARK: - UNUserNotificationCenterDelegate Methods
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle foreground notifications
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification response
        let userInfo = response.notification.request.content.userInfo
        print("Received notification with userInfo: \(userInfo)")
        
        // Handle the notification action here
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        // Handle notification settings
        print("Opening notification settings")
    }
}


private extension AppDelegate {
    // MARK: - App Lock Handling
    func setupAppLockObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIScene.willDeactivateNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIScene.didActivateNotification,
            object: nil
        )
    }
    
    @objc func appWillResignActive() {
        // App is going to background or inactive state, show app lock screen
        if shouldShowLockScreen {
            addAppLockView()
        }
    }
    
    @objc func appDidBecomeActive() {
        // App is coming to foreground, remove app lock screen
        if shouldShowLockScreen {
            removeAppLockView()
        }
    }
    
    func addAppLockView() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        guard !appLockView.isDescendant(of: window) else { return } // Avoid adding multiple times
        window.addSubview(appLockView)
        NSLayoutConstraint.activate([
            appLockView.topAnchor.constraint(equalTo: window.topAnchor),
            appLockView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            appLockView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            appLockView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
        window.bringSubviewToFront(appLockView)
    }
    
    func removeAppLockView() {
        appLockView.removeFromSuperview()
    }
}
