//
//  NuggetService.swift
//  NuggetSDKExample
//
//  Created by Rajesh Budhiraja on 05/06/25.
//

import Foundation
import NuggetSDK
import UIKit

/// The single integration point between the host app and the Nugget chat SDK — a holder of the
/// SDK's two long-lived objects as **shared static** members:
///
/// 1. ``notificationListener`` — the one ``NuggetPushNotificationsListener``. **Every** APNs token
///    / permission update flows through this instance and nowhere else (`AppDelegate` forwards them
///    here). `static let` ⇒ created once, lazily, shared for the app's lifetime.
/// 2. ``factory`` — the one ``NuggetFactory``, also `static` + lazy. Building it wires
///    ``notificationListener`` into the SDK (the factory becomes the listener's *upload delegate*),
///    which is what lets the forwarded token upload. Because the listener and factory share the
///    app's lifetime, the listener never loses its uploader to a screen being torn down.
///
/// The factory is built **lazily** — only when a chat is first opened (``getNuggetVC(deeplink:)``)
/// — so a normal launch creates no factory. Callers use the static API; there is no per-screen
/// instance to construct. The SDK's delegate callbacks (auth, theme, fonts, …) are served by a
/// single private ``delegates`` instance that lives for the app's lifetime.
///
/// All push-notification helpers (token plumbing, deeplink ownership checks, foreground
/// presentation) hang off `NuggetPushNotificationsListener` in `NuggetPushNotifications.swift`.
final class NuggetService {

    /// The one app-wide APNs listener. **Every** APNs token / permission update goes through this —
    /// and nowhere else. `static let` ⇒ created lazily on first use, shared everywhere.
    static let notificationListener = NuggetPushNotificationsListener(
        apnsToken: UserDefaults.standard.string(forKey: NuggetPushNotificationsListener.deviceTokenDefaultsKey)
    )

    /// The one Nugget factory — created **lazily** on first access (i.e. first chat open) and shared
    /// for the app's lifetime. It is wired to ``notificationListener`` (the factory becomes the
    /// listener's upload delegate), so the token forwarded to the listener is uploaded by this
    /// factory. A normal launch never touches it, so no factory is built up front.
    static let factory: NuggetFactory = initializeNuggetFactory(
        authDelegate: NuggetService.delegates,
        sdkConfigurationDelegate: NuggetService.delegates,
        notificationDelegate: NuggetService.notificationListener,
        chatBusinessContextDelegate: NuggetService.delegates,
        deeplinkListener: NuggetService.delegates,
        customThemeProviderDelegate: NuggetService.delegates,
        customFontProviderDelegate: NuggetService.delegates,
        ticketCreationDelegate: NuggetService.delegates
    )

    /// Builds (but does not present) the Nugget chat view controller for a deeplink. Touching this
    /// is what lazily creates ``factory``.
    ///
    /// - Parameter deeplink: A Nugget deeplink, e.g. `nugget://unified-support/room?...`.
    /// - Returns: The chat view controller, or `nil` if the deeplink is not one Nugget can open.
    static func getNuggetVC(deeplink: String) -> UIViewController? {
        factory.contentViewController(deeplink: deeplink)
    }

    /// The single instance backing the SDK's delegate callbacks (auth, theme, fonts, …). Private —
    /// callers use the static API above; this just gives the static ``factory`` an object to talk
    /// to, and lives for the app's lifetime so the SDK's weak delegate references stay valid.
    private static let delegates = NuggetService()

    /// Access token used by the auth delegate. Replace with a real token from your auth backend.
    let ACCESS_TOKEN = "YOUR_ACCESS_TOKEN_HERE"
    private init() {}
}

// MARK: - NuggetAuthProviderDelegate

extension NuggetService: NuggetAuthProviderDelegate {

    /// Concrete auth payload handed back to the SDK. `accessToken` is the only field the SDK
    /// strictly needs; the rest describe the signed-in user.
    struct NuggetAuthUserInfoImp: NuggetAuthUserInfo {
        var clientID: Int = 1
        var userName: String? = nil
        var userID: String = ""
        var photoURL: String = ""
        var accessToken: String = ""
    }

    /// Called by the SDK when it needs the current user's auth info (e.g. on chat open).
    ///
    /// Fetch / read your access token here and hand it back through `completion`.
    /// - Parameter completion: Pass the populated auth info, or an error if it can't be provided.
    func authManager(requiresAuthInfo completion: @escaping ((NuggetAuthUserInfo)?, (any Error)?) -> Void) {
        // Make an API call to fetch the access token, or read it from your cache.
        completion(NuggetAuthUserInfoImp(accessToken: ACCESS_TOKEN), nil)
    }

    /// Called by the SDK when its cached token is rejected/expired and must be refreshed.
    /// - Parameter completion: Pass a freshly refreshed token, or an error on failure.
    func authManager(requestRefreshAuthInfo completion: @escaping ((NuggetAuthUserInfo)?, (any Error)?) -> Void) {
        // The access token is expired. Refresh it and return the new one.
        completion(NuggetAuthUserInfoImp(accessToken: ACCESS_TOKEN), nil)
    }
}

// MARK: - NuggetSDKConfigurationDelegate

extension NuggetService: NuggetSDKConfigurationDelegate {

    /// Invoked when the chat screen is dismissed. Hook any teardown / analytics here.
    func chatScreenClosedCallback() {}

    /// Async variant the SDK uses to fetch the Jumbo (analytics) configuration.
    func jumboConfiguration(completion: @escaping (NuggetJumboConfiguration) -> Void) {
        completion(jumboConfiguration())
    }

    /// The Jumbo analytics configuration. `nameSpace` scopes this app's analytics stream.
    func jumboConfiguration() -> NuggetJumboConfiguration {
        NuggetJumboConfiguration(nameSpace: "NuggetSDKTest")
    }
}

// MARK: - NuggetBusinessContextProviderDelegate

extension NuggetService: NuggetBusinessContextProviderDelegate {

    /// Optional business context attached to a chat/ticket: routing handle, ticket grouping,
    /// and custom ticket/bot properties. All fields are optional.
    struct ChatSupportBusinessContext: NuggetChatBusinessContext {
        var type: String?
        var ticketID: Int?
        var channelHandle: String?
        var ticketGroupingId: String?
        var ticketProperties: [String : [String]]?
        var botProperties: [String : [String]]?
    }

    /// Supplies the business context the SDK should attach to the conversation.
    func chatSupportBusinessContext(completion: @escaping (NuggetBusinessContext) -> Void) {
        completion(ChatSupportBusinessContext())
    }
}

// MARK: - NuggetThemeProviderDelegate

extension NuggetService: NuggetThemeProviderDelegate {

    /// Accent color used by the SDK in light mode (hex).
    var defaultLightModeAccentHexColor: String {
        "#7C8363"
    }

    /// Accent color used by the SDK in dark mode (hex).
    var defaultDarkModeAccentHexColor: String {
        "#31473A"
    }

    /// Interface style the SDK should render in. `.unspecified` follows the system setting.
    var deviceInterfaceStyle: UIUserInterfaceStyle {
        .unspecified
    }
}

// MARK: - NuggetDeeplinkListener

extension NuggetService: NuggetDeeplinkListener {

    /// Called when a deeplink is invoked from *inside* a Nugget chat surface (e.g. a bot button).
    ///
    /// Route it through your app's own deeplink handling. This is distinct from handling a
    /// *push-notification* tap — see `NuggetPushNotifications.swift` for that.
    /// - Parameter deeplink: The URL the chat surface asked the host app to open.
    func deeplinkInvoked(deeplink: URL?) {
        print("Deeplink triggerred : \(String(describing: deeplink))")
    }
}

// MARK: - NuggetTicketCreationDelegate

extension NuggetService: NuggetTicketCreationDelegate {

    /// Called when a support ticket is successfully created.
    /// - Parameter conversationID: The conversation/ticket identifier created by the backend.
    func ticketCreationSucceeded(with conversationID: String) {
        print("Ticket created successfully with conversation ID : \(conversationID)")
    }

    /// Called when ticket creation fails.
    /// - Parameter errorMessage: A human-readable failure reason, if the SDK provided one.
    func ticketCreationFailed(withError errorMessage: String?) {
        print(errorMessage ?? "Ticket creation failed")
    }
}

// MARK: - NuggetFontProviderDelegate

extension NuggetService: NuggetFontProviderDelegate {

    /// Maps the SDK's semantic font weights / sizes onto a custom font family.
    struct CustomFontMap: NuggetFontPropertiesMapping {
        var fontName: String = "PlaywriteHU"

        var fontFamily: String = "Thin"

        var fontWeightMapping: [NuggetFontWeights : String] = [.light: "PlaywriteHU-Thin",
                                                               .regular: "PlaywriteHU-Thin",
                                                               .medium: "PlaywriteHU-Thin",
                                                               .semiBold: "PlaywriteHU-Thin",
                                                               .bold: "PlaywriteHU-Thin",
                                                               .extraBold: "PlaywriteHU-Thin",
                                                               .black: "PlaywriteHU-Thin"]

        /// Maps each semantic font size to a concrete point size.
        func fontSizeMapping(fontSize: NuggetFontSizes) -> Int {
            switch fontSize {
            case .font050:
                8
            case .font100:
                10
            case .font200:
                12
            case .font300:
                14
            case .font400:
                16
            case .font500:
                18
            case .font600:
                20
            case .font700:
                22
            case .font800:
                24
            case .font900:
                26
            @unknown default:
                14
            }
        }
    }

    /// The custom font mapping the SDK should use. Return `nil` to use the SDK's default fonts.
    var customFontMapping: (any NuggetFontPropertiesMapping)? {
        CustomFontMap()
    }
}
