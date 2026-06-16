//
//  AppDelegate.swift
//  NuggetSDKExample
//
//  Created by Rajesh Budhiraja on 05/06/25.
//

import UIKit
import CoreData
import UserNotifications
import NuggetSDK

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

        // 1. Become the notification-center delegate BEFORE launch finishes. Required so that
        //    `willPresent` (foreground) and `didReceive` (tap) callbacks reach us.
        UNUserNotificationCenter.current().delegate = self

        // 2. Ask for permission, forward the result to Nugget, and register with APNs on grant.
        //    (The factory that uploads the token is created lazily by the UI layer on first chat
        //    open — see `ViewController` — so nothing is built here.)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            // Forward the (possibly just-changed) permission status to Nugget's static listener.
            NuggetService.notificationListener.refreshPermissionStatus()

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

    // MARK: - APNs Registration

    /// APNs handed us the device token — forward it to the listener so the backend can target this
    /// device.
    ///
    /// The listener hex-encodes the token, caches it, and (once the chat factory exists) uploads it
    /// to Nugget. If you also use FCM, set `Messaging.messaging().apnsToken` here too (and disable
    /// FCM method swizzling) — Nugget needs the **raw APNs token**, not the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")

        // Hand the raw token to Nugget's single static listener.
        NuggetService.notificationListener.updateNotificationToken(deviceToken)
    }

    /// APNs registration failed (e.g. no network, no entitlement, Simulator without a signed-in
    /// Apple ID). Nugget simply won't receive a token this session.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// A notification arrived while the app is in the **foreground** (in-app notification).
    ///
    /// We ask the listener how to present it. By default a Nugget push is shown as a banner;
    /// pass `isViewingChat: true` to suppress it when the user is already in that conversation.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // Hook your own "is this chat already on screen?" logic in place of `false`.
        let isViewingChat = false

        let options = NuggetService.notificationListener.foregroundPresentationOptions(
            for: userInfo,
            isViewingChat: isViewingChat
        )
        completionHandler(options)
    }

    /// The user **tapped** a notification.
    ///
    /// If it's a Nugget push we extract its deeplink and hand it to the UI layer to open — building
    /// the chat screen needs the factory, which lives in the UI layer, so `AppDelegate` stays
    /// factory-free. Otherwise we fall through to the app's own deeplink handling.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }

        let userInfo = response.notification.request.content.userInfo
        print("Received notification with userInfo: \(userInfo)")

        // Is this a Nugget notification? If so, hand its deeplink to the UI layer to open — building
        // the chat screen needs the factory, which lives there (see `ViewController.openNugget(with:)`).
        guard
            let deeplink = NuggetService.notificationListener.nuggetDeeplink(in: userInfo),
            NuggetService.notificationListener.canOpenNuggetDeeplink(deeplink)
        else {
            // Not a Nugget notification — route it through your own deeplink / notification handling.
            return
        }
        // Build and present the Nugget chat screen from the UI layer.
        ViewController().openNugget(with: deeplink)
    }
}

// MARK: - App Lock Handling

private extension AppDelegate {

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
