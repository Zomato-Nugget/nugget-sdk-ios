# Nugget iOS SDK

`NuggetSDK` is the iOS distribution of **Nugget** — Zomato's in-app chat / customer-support
SDK. This repository is the **wrapper** that consumer apps integrate: it vendors the
`Nugget.xcframework` binary and exposes a friendly, typealiased Swift API (`Nugget*`).

- **Current version:** `4.5.32`
- **Integration:** Swift Package Manager or CocoaPods
- A runnable reference integration lives in [`NuggetSDKExample/`](NuggetSDKExample).

## Requirements

- iOS **14.0+**
- Swift 5 / Xcode 16 (supported up to Xcode 16.2)

## Installation

### Swift Package Manager

Add the package to your project (Xcode → *Add Package Dependencies…*) or in `Package.swift`:

```swift
.package(url: "https://github.com/Zomato-Nugget/nugget-sdk-ios", from: "4.5.32")
```

Then add `NuggetSDK` to your target's dependencies.

### CocoaPods

```ruby
pod 'NuggetSDK', :git => 'https://github.com/Zomato-Nugget/nugget-sdk-ios', :tag => '4.5.32'
```

```bash
pod install
```

## Usage

### 1. Initialize the factory

The SDK is driven by a `NuggetFactory`, created via the `initializeNuggetFactory(...)` helper.
You supply a set of delegates — two are required, the rest are optional.

```swift
import NuggetSDK

let factory = initializeNuggetFactory(
    authDelegate: self,                 // required — provides the access token
    sdkConfigurationDelegate: self,     // required — provides the Jumbo (analytics) config
    notificationDelegate: notificationListener, // push-notification listener (or nil)
    chatBusinessContextDelegate: self,  // optional — routing / ticket context
    deeplinkListener: self,             // optional — in-chat deeplink callbacks
    customThemeProviderDelegate: self,  // optional — accent colors / interface style
    customFontProviderDelegate: self,   // optional — custom fonts
    ticketCreationDelegate: self,       // optional — ticket success/failure callbacks
)
```

See [`NuggetSDKExample/NuggetSetup/NuggetService.swift`](NuggetSDKExample/NuggetSDKExample/NuggetSetup/NuggetService.swift)
for a fully documented implementation of every delegate.

| Delegate | Required? | Responsibility |
|----------|:---------:|----------------|
| `NuggetAuthProviderDelegate` | ✅ | Provide and refresh the user's access token. |
| `NuggetSDKConfigurationDelegate` | ✅ | Provide the Jumbo analytics config (`nameSpace`); chat-closed callback. |
| `NuggetPushNotificationsListener` | ⬜︎ | Carry the APNs token + permission to Nugget (see [Push Notifications](#2-push-notifications)). Pass `nil` for internal clients. |
| `NuggetBusinessContextProviderDelegate` | ⬜︎ | Attach routing / ticket / bot context to the conversation. |
| `NuggetDeeplinkListener` | ⬜︎ | Receive deeplinks fired from inside a chat surface. |
| `NuggetThemeProviderDelegate` | ⬜︎ | Accent colors and light/dark interface style. |
| `NuggetFontProviderDelegate` | ⬜︎ | Map the SDK's semantic fonts to a custom family. |
| `NuggetTicketCreationDelegate` | ⬜︎ | Ticket-created success / failure callbacks. |

`initializeNuggetFactory(...)` also accepts three further optional delegates (all default `nil`) for
advanced use: `conversationSessionDelegate`, `chatComponentProviderDelegate`, and
`customHeaderManagerDelegate`.

Omit the parameter (or pass `[:]`) to leave every flag off. Contact the Nugget team for the full
set of supported flags and their behavior.

### 2. Push Notifications

Push notifications have a dedicated, in-depth guide:
**[docs/PushNotifications.md](docs/PushNotifications.md)**. In short:

1. **Create a listener** and pass it as `notificationDelegate`:

   ```swift
   let notificationListener = NuggetPushNotificationsListener(
       apnsToken: UserDefaults.standard.string(forKey: "deviceToken")
   )
   ```

2. **Forward the APNs token and permission** from your `AppDelegate` — the listener uploads them
   to Nugget so the backend can target this device:

   ```swift
   notificationListener.tokenUpdated(to: deviceToken)                  // from didRegister… (raw Data)
   notificationListener.permissionStatusUpdated(to: settings.authorizationStatus)
   ```

   > Nugget needs the **raw APNs device token**, not an FCM token. If you also use FCM, disable
   > swizzling and forward the same raw APNs token to both — see the
   > [guide](docs/PushNotifications.md#using-firebase-cloud-messaging-fcm-as-well).

3. **Handle a notification tap** — a Nugget push carries its deeplink under `meta.deeplink`.
   In `didReceive`, validate it and build the chat screen:

   ```swift
   guard
       let deeplink = (userInfo["meta"] as? [String: Any])?["deeplink"] as? String,
       NuggetFactory.canOpenDeeplink(deeplink: deeplink),             // is it a Nugget deeplink?
       let chatVC = factory.contentViewController(deeplink: deeplink)
   else { return }
   // present `chatVC`
   ```

The example app implements all of this — registration, token upload, tap handling, and in-app
banners — in
[`NuggetPushNotifications.swift`](NuggetSDKExample/NuggetSDKExample/NuggetSetup/NuggetPushNotifications.swift)
and [`AppDelegate.swift`](NuggetSDKExample/NuggetSDKExample/AppDelegate.swift).

### 3. Opening chat from a deeplink

```swift
let deeplink = "nugget://unified-support/room?flowType=ticketing&ticketID=17022537"

if NuggetFactory.canOpenDeeplink(deeplink: deeplink),
   let chatVC = factory.contentViewController(deeplink: deeplink) {
    navigationController?.pushViewController(chatVC, animated: true)
}
```

`canOpenDeeplink(deeplink:)` returns `true` only for Nugget hosts — `chat`, `zchat`, or
`unified-support`. The wrapper also exposes a free function `isValidNuggetDeeplink(deeplink:)`
that does the same check.

### 4. Logout

Clear the device token on the backend when the user signs out:

```swift
factory.resetNuggetSDK { success in
    print("Nugget notification token reset: \(success)")
}
```

## API reference

| Symbol | Kind | Notes |
|--------|------|-------|
| `initializeNuggetFactory(authDelegate:sdkConfigurationDelegate:notificationDelegate:…)` | global func → `NuggetFactory` | Builds and returns the factory. |
| `NuggetFactory.contentViewController(deeplink:)` | method → `UIViewController?` | Builds the chat screen for a deeplink. |
| `NuggetFactory.canOpenDeeplink(deeplink:)` | static func → `Bool` | `true` for hosts `chat` / `zchat` / `unified-support`. |
| `isValidNuggetDeeplink(deeplink:)` | global func → `Bool` | Convenience alias of the above. |
| `NuggetFactory.resetNuggetSDK(completionHandler:)` | method | Clears the device token on logout. |
| `NuggetPushNotificationsListener.tokenUpdated(to:)` | method | Forward the APNs token (`Data` or hex `String`). |
| `NuggetPushNotificationsListener.permissionStatusUpdated(to:)` | method | Forward the `UNAuthorizationStatus`. |

## Example app

[`NuggetSDKExample`](NuggetSDKExample) is a complete, documented integration — factory setup,
every delegate, and the full push-notification flow (registration, token upload, tap handling,
in-app banners).

## Troubleshooting

1. **Module not found** — confirm `NuggetSDK` is added to your target; clean build folder and
   re-resolve packages / `pod install`.
2. **Authentication errors** — verify the `accessToken` returned from
   `NuggetAuthProviderDelegate`.
3. **Deeplink not opening** — check `NuggetFactory.canOpenDeeplink(deeplink:)` first.
4. **Pushes not arriving** — make sure the APNs token is forwarded via `tokenUpdated(to:)` *after*
   the factory exists, and that you passed the **raw APNs token** (not an FCM token).

For additional support, please contact the Nugget team.
