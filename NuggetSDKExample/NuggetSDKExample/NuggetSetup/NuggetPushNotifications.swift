//
//  NuggetPushNotifications.swift
//  NuggetSDKExample
//
//  Push-notification integration for the Nugget chat SDK.
//
//  Everything here hangs off `NuggetPushNotificationsListener` — the single APNs object owned by
//  `AppDelegate`. AppDelegate forwards the device token and permission status to it, and the chat
//  factory (in `NuggetService`) is built with the *same* listener, so those updates are what
//  actually upload to Nugget's backend.
//
//  Responsibilities:
//    1. Token plumbing      — forward the APNs device token / permission to Nugget
//                             (`updateNotificationToken(_:)`, `updateNotificationPermissionStatus(_:)`,
//                             `refreshPermissionStatus()`).
//    2. Ownership check      — decide whether a given push / deeplink belongs to Nugget
//                             (`canOpenNuggetDeeplink(_:)`, `nuggetDeeplink(in:)`, `isNuggetNotification(_:)`).
//    3. Foreground behaviour — decide how to present a Nugget push while foregrounded
//                             (`foregroundPresentationOptions(for:isViewingChat:)`).
//
//  Building the chat screen for a tapped push needs the factory, which lives in the UI layer
//  (`NuggetService.getNuggetVC(deeplink:)`). AppDelegate only extracts the deeplink here and
//  hands it to the UI layer (`ViewController.openNugget(with:)`) to open — it never builds a factory.
//

import Foundation
import NuggetSDK
import UIKit
import UserNotifications


// MARK: - Notification payload keys
extension NuggetPushNotificationsListener {

    /// Keys used inside a Nugget push-notification payload.
    ///
    /// A Nugget push looks like:
    /// ```json
    /// {
    ///   "aps": { "alert": { "title": "...", "body": "..." }, "sound": "default" },
    ///   "meta": {
    ///     "deeplink": "nugget://unified-support/room?flowType=ticketing&ticketID=1234567",
    ///     "track_id": "01KTRT...:omniTicketing-12345",
    ///     "notification_id": "notif:omniTicketing-1234567"
    ///   }
    /// }
    /// ```
    /// The actionable bits live under `meta`.
    enum NotificationPayloadKey {
        /// Top-level dictionary holding Nugget metadata.
        static let meta = "meta"
        /// The Nugget deeplink to open when the notification is tapped.
        static let deeplink = "deeplink"
    }

    /// `UserDefaults` key under which the last-known APNs device token (hex string) is cached, so
    /// the listener can be seeded with it on the next launch (see `AppDelegate`'s listener init).
    static let deviceTokenDefaultsKey = "deviceToken"
}

// MARK: - Token & permission plumbing

extension NuggetPushNotificationsListener {

    /// Forwards a freshly registered APNs device token to Nugget.
    ///
    /// Call from `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`. The raw `Data`
    /// is hex-encoded by the SDK, so you can hand the token straight through. It is also cached in
    /// `UserDefaults` so the listener can be seeded with it on the next launch.
    ///
    /// - Parameter deviceToken: The token `Data` supplied by APNs.
    func updateNotificationToken(_ deviceToken: Data) {
        let hexToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(hexToken, forKey: Self.deviceTokenDefaultsKey)
        tokenUpdated(to: deviceToken)
    }

    /// Forwards an APNs device token (already hex-encoded) to Nugget.
    ///
    /// Use this overload when you are also using FCM and already hold the APNs token as a string.
    /// - Parameter hexToken: The APNs device token as a hex string.
    func updateNotificationToken(_ hexToken: String) {
        UserDefaults.standard.set(hexToken, forKey: Self.deviceTokenDefaultsKey)
        tokenUpdated(to: hexToken)
    }

    /// Tells Nugget whether the user has granted notification permission.
    ///
    /// The listener forwards this to Nugget's backend (alongside the token) so the server knows
    /// whether this device can currently receive pushes.
    /// - Parameter status: The current `UNAuthorizationStatus`.
    func updateNotificationPermissionStatus(_ status: UNAuthorizationStatus) {
        permissionStatusUpdated(to: status)
    }

    /// Reads the *current* system notification settings and forwards the authorization status.
    ///
    /// The permission can change outside the app (Settings app), so re-sync it whenever
    /// convenient — typically on launch and on `applicationDidBecomeActive`.
    func refreshPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            self?.permissionStatusUpdated(to: settings.authorizationStatus)
        }
    }
}

// MARK: - Deeplink / ownership checks

extension NuggetPushNotificationsListener {

    /// Returns whether the given deeplink is one the Nugget SDK can open.
    ///
    /// Thin wrapper over `NuggetFactory.canOpenDeeplink(deeplink:)` (a static check — no factory
    /// instance required). Returns `true` only for Nugget hosts (`chat`, `zchat`,
    /// `unified-support`).
    ///
    /// - Parameter deeplink: The deeplink string to validate.
    /// - Returns: `true` if Nugget should handle it.
    func canOpenNuggetDeeplink(_ deeplink: String) -> Bool {
        NuggetFactory.canOpenDeeplink(deeplink: deeplink)
    }

    /// Extracts the Nugget deeplink from a remote-notification `userInfo` payload, if present.
    ///
    /// - Parameter userInfo: The notification's `userInfo` dictionary.
    /// - Returns: The `meta.deeplink` string, or `nil` if the payload has no Nugget deeplink.
    func nuggetDeeplink(in userInfo: [AnyHashable: Any]) -> String? {
        guard
            let meta = userInfo[NotificationPayloadKey.meta] as? [String: Any],
            let deeplink = meta[NotificationPayloadKey.deeplink] as? String
        else { return nil }
        return deeplink
    }

    /// Returns whether a remote-notification payload originated from Nugget.
    ///
    /// A payload is a Nugget notification when it carries a `meta.deeplink` that the SDK can open.
    /// - Parameter userInfo: The notification's `userInfo` dictionary.
    /// - Returns: `true` if this notification belongs to Nugget.
    func isNuggetNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        guard let deeplink = nuggetDeeplink(in: userInfo) else { return false }
        return canOpenNuggetDeeplink(deeplink)
    }
}

// MARK: - Foreground presentation

extension NuggetPushNotificationsListener {

    /// Decides how a notification should be presented while the app is in the **foreground**.
    ///
    /// Call from `userNotificationCenter(_:willPresent:withCompletionHandler:)`. By default a
    /// Nugget push is shown as a normal banner. You can suppress it (return `[]`) when the user is
    /// already looking at the exact chat the push refers to — pass `isViewingChat: true` for that
    /// case so the banner doesn't become noise. Non-Nugget notifications are always shown as a
    /// banner (let your own logic decide otherwise upstream if needed).
    ///
    /// - Parameters:
    ///   - userInfo: The incoming notification's `userInfo` dictionary.
    ///   - isViewingChat: Whether the user is already viewing the chat this push refers to.
    /// - Returns: The presentation options to pass to the completion handler.
    func foregroundPresentationOptions(
        for userInfo: [AnyHashable: Any],
        isViewingChat: Bool = false
    ) -> UNNotificationPresentationOptions {
        if isNuggetNotification(userInfo), isViewingChat {
            return [] // Suppress — the user is already in this conversation.
        }
        return [.banner, .sound, .badge]
    }
}
