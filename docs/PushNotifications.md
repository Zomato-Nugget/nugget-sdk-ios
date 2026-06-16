# Push Notifications — Setup Guide (NuggetSDK, iOS)

How push notifications are wired up end‑to‑end in the **NuggetSDK** (`nugget-sdk-ios`)
distribution wrapper: registering for APNs, handing the **APNS device token** to Nugget so
the backend can target the device, and handling a notification **tap** by parsing the
Nugget deeplink and opening the right chat screen.

> All APIs below are the friendly `NuggetSDK` wrapper types (`import NuggetSDK`).

> **The full, build‑verified implementation lives in the example app** — this guide explains
> *what* each piece does and shows only the essential calls. Read alongside:
> - [`NuggetPushNotifications.swift`](../NuggetSDKExample/NuggetSDKExample/NuggetSetup/NuggetPushNotifications.swift)
>   — `NuggetPushNotificationsListener` helpers: token / permission plumbing,
>   `canOpenNuggetDeeplink(_:)`, `nuggetDeeplink(in:)`, `foregroundPresentationOptions(for:)`.
> - [`AppDelegate.swift`](../NuggetSDKExample/NuggetSDKExample/AppDelegate.swift) — wires the
>   system notification callbacks (token, permission, tap) into the static listener.
> - [`NuggetService.swift`](../NuggetSDKExample/NuggetSDKExample/NuggetSetup/NuggetService.swift)
>   — holds the **single static listener** and the **single lazy static factory**, and builds the
>   chat screen via `NuggetService.getNuggetVC(deeplink:)`.

> **Ownership at a glance.** Both SDK objects are **shared static members of `NuggetService`**:
> `NuggetService.notificationListener` (the one `NuggetPushNotificationsListener` — **every** APNs
> token / permission update flows through it and nowhere else) and `NuggetService.factory` (the one
> `NuggetFactory`, created **lazily** on first chat open and wired to that listener, so the
> forwarded token uploads). `AppDelegate` owns neither — it just forwards APNs updates to the static
> listener, and on a tapped push forwards the deeplink to the UI layer to open. Both objects share
> the app's lifetime, so the listener never loses its uploader to a screen being torn down.

---

## 1. The flow at a glance

```
┌──────────────┐  register   ┌──────────────┐  APNS token   ┌──────────────────────────────┐
│  Your App    │ ──────────▶ │  APNs        │ ────────────▶ │ AppDelegate                  │
│ (AppDelegate)│             │  (Apple)     │   (Data)      │ didRegisterFor…DeviceToken   │
└──────────────┘             └──────────────┘               └───────────────┬──────────────┘
                                                          NuggetService.notificationListener
                                                            .updateNotificationToken(_:)
                                                                            ▼
                                       ┌────────────────────────────────────────────────────┐
                                       │ NuggetService.notificationListener (static, shared)   │
                                       │  caches the token; uploads it ONCE the factory exists │
                                       └───────────────┬────────────────────────────────────┘
                                                       │ wired in as notificationDelegate
                                                       ▼
                                       ┌────────────────────────────────────────────────────┐
                                       │ NuggetService.factory (static, shared)                │
                                       │  created lazily on first chat open — not up front     │
                                       └────────────────────────────────────────────────────┘

  ── Nugget backend sends a push ──────────────────────────────────────────────────────────▶

┌──────────────┐  user taps  ┌──────────────────────────────┐  meta.deeplink  ┌─────────────────────────┐
│ Notification │ ──────────▶ │ AppDelegate                  │ ──────────────▶ │ NuggetService.          │
│  banner      │             │ didReceive response          │   (validate)    │ notificationListener    │
└──────────────┘             └───────────────┬──────────────┘                 └────────────┬────────────┘
                                             │ forward deeplink                              │ true
                                             ▼                                               ▼
                            UI layer: NuggetService.getNuggetVC(deeplink:) ──▶ push chat screen
```

There are **two responsibilities** you implement:

1. **Token plumbing** — give Nugget the APNS device token (and permission status) so the
   backend knows where to deliver chat notifications. Forward both to the one static listener,
   `NuggetService.notificationListener` — **and nowhere else**.
2. **Tap handling** — when a Nugget notification is tapped, validate its deeplink with the
   listener (`canOpenNuggetDeeplink(_:)`), then open the chat screen **from the UI layer** with
   `NuggetService.getNuggetVC(deeplink:)` (which wraps `factory.contentViewController(deeplink:)`).
   The static factory is created only at this point — not up front.

---

## 2. Prerequisites

- **Push Notifications** capability enabled in your target (Signing & Capabilities).
- **Background Modes → Remote notifications** if you want background/data pushes.
- A configured **APNs key/cert** on the Nugget backend for your app's bundle id
  (e.g. `com.zomato.zync` in the sample payload).
- NuggetSDK integrated and `initializeNuggetFactory(...)` already set up
  (see [`NuggetService.swift`](../NuggetSDKExample/NuggetSDKExample/NuggetSetup/NuggetService.swift)).

---

## 3. Step 1 — Create the listener and pass it to the factory

`NuggetPushNotificationsListener` receives the APNS token and permission status and
**automatically uploads** them to the Nugget backend (via an internal Combine pipeline)
whenever either changes — you never call an "upload" method yourself. Keep **one** listener for
the whole app and pass that **same** instance to the factory as `notificationDelegate`. In the
example both live as static members of `NuggetService`:

```swift
final class NuggetService {

    // The ONE listener — every APNS token / permission update goes through this, nowhere else.
    static let notificationListener = NuggetPushNotificationsListener(
        apnsToken: UserDefaults.standard.string(forKey: "deviceToken")
    )

    // The ONE factory — created lazily, wired to that same listener.
    static let factory = initializeNuggetFactory(
        authDelegate: delegates,
        sdkConfigurationDelegate: delegates,
        notificationDelegate: notificationListener,   // 👈 the single static listener
        // …other delegates…
    )

    // Backs the SDK delegate callbacks (auth, theme, fonts, …); kept alive for the app's lifetime.
    private static let delegates = NuggetService()
    private init() {}
}
```

> The SDK delegate callbacks (auth, theme, fonts, …) need an object, so the example backs them
> with a single private `delegates` instance — see `NuggetService.swift`. Everyone else uses the
> static API: `NuggetService.notificationListener` and `NuggetService.getNuggetVC(deeplink:)`.

> **The listener can only upload once a factory is created with it.** The factory wires itself in
> as the listener's upload delegate, so a token forwarded *before* any factory exists is held (and
> cached) but not uploaded yet. **Creating a factory is not required up front** — it is built
> **lazily, only when a chat is first opened** (`getNuggetVC(deeplink:)`), and the cached token
> uploads at that point. A normal launch builds no factory. If you specifically want the token
> uploaded at launch, create the factory eagerly wherever your app owns it.

> `notificationDelegate` accepts `nil`: internal Zomato clients pass `nil` (the backend already
> routes their pushes); external clients integrating Nugget for their own support flow pass a
> real listener.

### Listener API reference

| Member | Purpose |
|--------|---------|
| `init(apnsToken: String? = nil, pushNotificationPermissionStatus: UNAuthorizationStatus? = nil)` | Create the listener, optionally seeded with a cached token / status. |
| `tokenUpdated(to newToken: String)` | Update the APNS token from a hex string. |
| `tokenUpdated(to newToken: Data)` | Update the APNS token from the raw `Data` Apple hands you — it is hex‑encoded for you. |
| `permissionStatusUpdated(to: UNAuthorizationStatus)` | Tell Nugget whether the user granted/denied notifications. |

The listener de‑dupes against the last‑uploaded value, so it's safe to call these liberally.

---

## 4. Step 2 — Register and forward the token / permission (AppDelegate)

In `didFinishLaunching`: set the notification‑center delegate, request authorization, forward
the permission status, and `registerForRemoteNotifications()`. Then forward the token from the
APNs callback. The two calls that actually feed Nugget are:

```swift
// In application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
NuggetService.notificationListener.tokenUpdated(to: deviceToken)   // raw Data is hex-encoded for you

// After requesting authorization (and again on didBecomeActive, since it can change in Settings)
UNUserNotificationCenter.current().getNotificationSettings { settings in
    NuggetService.notificationListener.permissionStatusUpdated(to: settings.authorizationStatus)
}
```

Full wiring (delegate, authorization request, registration, persistence) is in
[`AppDelegate.swift`](../NuggetSDKExample/NuggetSDKExample/AppDelegate.swift); the example wraps
both calls as `updateNotificationToken(_:)` / `refreshPermissionStatus()` — listener helpers in
[`NuggetPushNotifications.swift`](../NuggetSDKExample/NuggetSDKExample/NuggetSetup/NuggetPushNotifications.swift).

> **Seed *and* forward.** On the very first launch nothing is cached, so the `init(apnsToken:)`
> seed is `nil`; the `tokenUpdated(to:)` call in `didRegister…` is what delivers the token the
> first time and on every later rotation.

---

## 5. Generating an APNS device token

The token is produced by iOS — you *request* it and receive it in a delegate callback:

1. `UNUserNotificationCenter.current().requestAuthorization(options:)` — ask the user.
2. `UIApplication.shared.registerForRemoteNotifications()` — on a granted permission.
3. iOS calls back with either the token or an error:
   - `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` → raw `Data`.
   - `application(_:didFailToRegisterForRemoteNotificationsWithError:)` → failure.

To read it as a hex string (e.g. for logging), or pass the raw `Data` straight to Nugget:

```swift
let apnsToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
```

> APNs tokens are only delivered on a **real device** (and modern Simulators on macOS 13+ with a
> signed‑in Apple ID), and they **rotate** — always forward the latest one.

### Using Firebase Cloud Messaging (FCM) as well

Nugget needs the **raw APNS device token**, *not* the FCM registration token. If you also use
FCM, disable method swizzling and forward the same raw APNS token to both:

1. Add `FirebaseAppDelegateProxyEnabled = NO` (Boolean) to your **Info.plist**.
2. In `didRegisterForRemoteNotificationsWithDeviceToken`, set both:

```swift
Messaging.messaging().apnsToken = deviceToken                          // keep FCM working
NuggetService.notificationListener.tokenUpdated(to: deviceToken)       // give Nugget the RAW APNS token
```

Firebase's guide on disabling swizzling:
<https://firebase.google.com/docs/cloud-messaging/ios/get-started#disable-swizzling>

---

## 6. The Nugget notification payload

A Nugget push looks like this — the actionable bits live under **`meta`**:

```json
{
  "Simulator Target Bundle": "com.zomato.zync",
  "aps": {
    "alert": {
      "title": "Sample App",
      "body": "Agent replied: Hello, how can I help you?"
    },
    "sound": "default",
    "interruption-level": "time-sensitive"
  },
  "meta": {
    "deeplink": "nugget://unified-support/room?flowType=ticketing&omniTicketingFlow=true&ticketID=1234567",
    "track_id": "sdlkmsdcklwmdecl;ewkmc:omniTicketing-1234567",
    "notification_id": "notif:omniTicketing-12345677"
  }
}
```

| Field | Meaning |
|-------|---------|
| `aps.alert.title` / `aps.alert.body` | What iOS shows in the banner. |
| `aps.interruption-level` | `time-sensitive` so support replies break through Focus modes. |
| `meta.deeplink` | **The Nugget deeplink** to open on tap. Host = `unified-support` ⇒ a valid Nugget deeplink. |
| `meta.track_id` / `meta.notification_id` | Identifiers for analytics / de‑duplication. |

The deeplink encodes the destination: `flowType=ticketing`, `omniTicketingFlow=true`,
`ticketID=17022537` → open the ticketing conversation for that ticket.

---

## 7. Step 3 — Handle the notification tap (deeplink → chat screen)

On tap, iOS calls `userNotificationCenter(_:didReceive:withCompletionHandler:)` on the
`AppDelegate`. It **extracts and validates** the deeplink via the static listener, then hands it to
the UI layer — which builds the chat screen via `NuggetService.getNuggetVC(...)`. Splitting it this
way keeps the factory lazy (created only when a chat is actually opened) and `AppDelegate` free of
any UI/factory work:

```swift
// AppDelegate — validate + forward (no factory work here)
guard
    let deeplink = NuggetService.notificationListener.nuggetDeeplink(in: userInfo),   // meta.deeplink
    NuggetService.notificationListener.canOpenNuggetDeeplink(deeplink)                // a Nugget deeplink?
else { return }   // not a Nugget push → fall through to your own deeplink routing
// hand the validated deeplink to the UI layer to build + present the chat

// UI layer (ViewController) — build + present via the static factory
guard let chatVC = NuggetService.getNuggetVC(deeplink: deeplink) else { return }
navigationController?.pushViewController(chatVC, animated: true)
```

`canOpenNuggetDeeplink(_:)` / `nuggetDeeplink(in:)` are listener helpers; `getNuggetVC(deeplink:)`
wraps `factory.contentViewController(deeplink:)`. In the example, `AppDelegate` hands the validated
deeplink to the UI layer via `ViewController.openNugget(with:)`, which builds and pushes the chat —
see [`AppDelegate.swift`](../NuggetSDKExample/NuggetSDKExample/AppDelegate.swift) and
[`ViewController.swift`](../NuggetSDKExample/NuggetSDKExample/ViewController.swift).

> **`canOpenDeeplink` contract** — a static method on `NuggetFactory` that returns `true` only
> when the deeplink's **host** is `chat`, `zchat`, or `unified-support`. The sample payload's
> `nugget://unified-support/room?…` ⇒ host `unified-support` ⇒ `true`. The wrapper also exposes
> a free function `isValidNuggetDeeplink(deeplink:)` that does the same check.

---

## 8. Step 4 — Foreground (in‑app) notifications

For a push that arrives while the app is foregrounded, iOS calls `willPresent`; return the
presentation options. Show the banner normally, or return `[]` to suppress it (e.g. when the
user is already on that exact chat):

```swift
completionHandler([.banner, .sound, .badge])   // show — or [] to suppress
```

The example centralises this decision in a listener helper —
`NuggetService.notificationListener.foregroundPresentationOptions(for:isViewingChat:)`.

> Tapping the foreground banner still routes through `didReceive response` (Step 3), so the
> deeplink handling is shared — `willPresent` only decides whether to *display* the banner.

---

## 9. Related: clearing the token on logout

When the user logs out, tell Nugget to stop targeting this device:

```swift
NuggetService.factory.resetNuggetSDK { success in print("Nugget token reset: \(success)") }
```

This makes the backend call with the token removed / permission denied, and clears the locally
cached token.

---

## 10. Checklist

- [ ] Push Notifications capability (+ Background Modes if needed) enabled.
- [ ] `UNUserNotificationCenter.current().delegate = self` set before launch finishes.
- [ ] Exactly one `NuggetPushNotificationsListener` (here `static NuggetService.notificationListener`); the same instance is wired into the factory. **All** APNS token / permission updates go through it — nowhere else. (The factory is built lazily on first chat open — no need to create it up front; the cached token uploads then.)
- [ ] Permission requested; `permissionStatusUpdated(to:)` forwarded to that static listener.
- [ ] `registerForRemoteNotifications()` called after permission granted.
- [ ] `NuggetPushNotificationsListener` created and passed as `notificationDelegate` to `initializeNuggetFactory(...)`.
- [ ] APNS token forwarded via `tokenUpdated(to:)` in `didRegisterForRemoteNotificationsWithDeviceToken`.
- [ ] (FCM only) swizzling disabled; raw APNS token sent to *both* `Messaging` and Nugget.
- [ ] Tap handling: parse `meta.deeplink` → `NuggetFactory.canOpenDeeplink(deeplink:)` → `factory.contentViewController(deeplink:)`.
- [ ] Foreground `willPresent` returns the desired presentation options.

---

### API quick reference (NuggetSDK wrapper)

| Symbol | Kind | Notes |
|--------|------|-------|
| `NuggetPushNotificationsListener` | class (`= ZChatPushNotificationsListener`) | Holds the APNS token + permission; auto‑uploads to Nugget backend. |
| `…​.tokenUpdated(to: Data)` / `(to: String)` | method | Forward the APNS device token. |
| `…​.permissionStatusUpdated(to:)` | method | Forward the `UNAuthorizationStatus`. |
| `initializeNuggetFactory(…, notificationDelegate:)` | global func | Wires the listener into Nugget. |
| `NuggetFactory.canOpenDeeplink(deeplink:)` | static func → `Bool` | `true` for hosts `chat` / `zchat` / `unified-support`. |
| `isValidNuggetDeeplink(deeplink:)` | global func → `Bool` | Convenience alias of the above. |
| `factory.contentViewController(deeplink:)` | method → `UIViewController?` | Builds the chat screen for a deeplink. |
| `factory.resetNuggetSDK(completionHandler:)` | method | Clears the device token on logout. |
