# Push Notifications — Setup Guide (NuggetSDK, iOS)

How push is wired end‑to‑end in **NuggetSDK** (`nugget-sdk-ios`): register for APNs, hand the
**APNS device token** to Nugget so the backend can target the device, and open the right chat
screen when a notification is **tapped**. All APIs are the friendly `NuggetSDK` wrapper types
(`import NuggetSDK`).

> Note: The full, build‑verified implementation lives in the example app
> ([`NuggetSDKExample`](../NuggetSDKExample)): see
> [`NuggetService.swift`](../NuggetSDKExample/NuggetSDKExample/NuggetSetup/NuggetService.swift),
> [`NuggetPushNotifications.swift`](../NuggetSDKExample/NuggetSDKExample/NuggetSetup/NuggetPushNotifications.swift),
> [`AppDelegate.swift`](../NuggetSDKExample/NuggetSDKExample/AppDelegate.swift) and
> [`ViewController.swift`](../NuggetSDKExample/NuggetSDKExample/ViewController.swift).


## 1. Summary

**Mental model — two long‑lived objects:**

- **One listener** (`NuggetPushNotificationsListener`) — *every* APNS token / permission update
  goes through it, and nowhere else. It auto‑uploads to Nugget's backend.
- **One factory** (`NuggetFactory`) — built **lazily** on first chat open. Passing the listener to
  it as `notificationDelegate` is what lets the listener upload; the factory also builds the chat
  screen. A normal launch builds no factory (the cached token uploads on first chat open).

In the example both are shared `static` members of `NuggetService`. `AppDelegate` owns neither — it
just forwards APNs updates to the static listener, and on a tap forwards the deeplink to the UI
layer to open.

**Two responsibilities → six things you implement:**

| # | Where | What to do |
|---|-------|-----------|
| 1 | Your `NuggetService` | Keep **one** listener; pass it as `notificationDelegate` to `initializeNuggetFactory(...)`. |
| 2 | `didRegister…DeviceToken` | Forward the token: `listener.tokenUpdated(to: deviceToken)` (raw `Data` is hex‑encoded for you). |
| 3 | After `requestAuthorization` (+ recommended on `didBecomeActive`) | Forward permission: `listener.permissionStatusUpdated(to: status)`. |
| 4 | `didReceive` (tap) | Read `meta.deeplink` → validate it's a Nugget deeplink → build the chat VC → push it. Non‑Nugget pushes fall through to your own routing. |
| 5 | `willPresent` (foreground) | Return `[.banner, .sound, .badge]`, or `[]` to suppress when already in that chat. |
| 6 | On logout | `factory.resetNuggetSDK { _ in }` to stop targeting this device. |

**The flow, compact:**

```
register → APNs → AppDelegate.didRegister…Token → listener.tokenUpdated(to:)
                                                     │ (cached; uploads once a factory exists)
                                                     ▼
                          listener ──notificationDelegate──▶ factory (lazy, on first chat open)

backend push → user taps → AppDelegate.didReceive → meta.deeplink valid?
                                                       │ yes
                                                       ▼
                                  UI layer: factory.contentViewController(deeplink:) → push chat
```

> Note: Internal Zomato clients can pass `notificationDelegate: nil` — the backend already routes
> their pushes. External clients integrating Nugget for their own support flow pass a real listener.

---

## 2. AI prompt

Copy everything in the box below into any AI coding assistant (alongside your project) to implement
the integration in one pass. It is self‑contained — the exact SDK API, the ownership model, every
case, and acceptance criteria.

````text
You are integrating the **NuggetSDK** push‑notification flow into an existing iOS app
(Swift, UIKit, AppDelegate‑based). Goal: register for APNs, hand the device token + permission
status to Nugget so the backend can target the device, and open the Nugget chat screen when a
Nugget push is tapped. Match the existing app's style and AppDelegate structure.

## SDK API to use (imports needed: `NuggetSDK`, `UIKit`, `UserNotifications`)
- `NuggetPushNotificationsListener` — receives the APNS token + permission status and AUTO‑uploads
  them to Nugget's backend (internally, once a factory is wired to it). De‑dupes repeated values,
  so it's safe to call liberally.
    - init(apnsToken: String? = nil, pushNotificationPermissionStatus: UNAuthorizationStatus? = nil)
    - tokenUpdated(to: Data)    // pass the raw APNs Data — it is hex‑encoded for you
    - tokenUpdated(to: String)  // pass an already‑hex token
    - permissionStatusUpdated(to: UNAuthorizationStatus)
- `initializeNuggetFactory(authDelegate:sdkConfigurationDelegate:notificationDelegate: …) -> NuggetFactory`
  Pass your listener as `notificationDelegate`. The factory ALSO requires `authDelegate` (conforms to
  `NuggetAuthProviderDelegate`) and `sdkConfigurationDelegate` (conforms to
  `NuggetSDKConfigurationDelegate`), plus optional theme / font / deeplink / business-context /
  ticket delegates — back them all with one long-lived object. If the app already builds a factory
  for chat, just add your listener as its `notificationDelegate` — do NOT create a second factory.
- `NuggetFactory.canOpenDeeplink(deeplink: String) -> Bool`  // STATIC; true only for hosts
  `chat`, `zchat`, `unified-support`. `isValidNuggetDeeplink(deeplink:)` is an equivalent global func.
- `factory.contentViewController(deeplink: String) -> UIViewController?`  // builds the chat screen
- `factory.resetNuggetSDK(completionHandler: (Bool) -> Void)`            // clears the token on logout

## Ownership model (follow exactly)
- Keep EXACTLY ONE `NuggetPushNotificationsListener` for the whole app. EVERY token / permission
  update goes through it — nowhere else.
- Pass that same listener instance to `initializeNuggetFactory(..., notificationDelegate:)`. The
  factory becomes the listener's upload delegate, so a token forwarded BEFORE any factory exists is
  cached and uploads when the factory is first created.
- Build the factory LAZILY — only when the first chat opens. A normal launch builds no factory; the
  cached token uploads on first chat open. (To upload at launch instead, build the factory eagerly.)
- Hold both as shared statics on a `NuggetService` type: `static let notificationListener` (seed it
  with the last token cached in UserDefaults) and `static let factory = initializeNuggetFactory(...)`.
  Back the SDK's delegates (auth, config, theme, fonts, …) with one long‑lived private instance.
- Keep AppDelegate FREE of factory work: extract the deeplink there, open the chat from the UI layer.

## Implement
1. application(_:didFinishLaunchingWithOptions:):
   - set `UNUserNotificationCenter.current().delegate = self` BEFORE launch finishes.
   - `requestAuthorization(options: [.alert, .badge, .sound])`; in the completion forward the
     resulting status (`getNotificationSettings { listener.permissionStatusUpdated(to: $0.authorizationStatus) }`)
     and, if granted, call `UIApplication.shared.registerForRemoteNotifications()` on the main thread.
   - (Recommended) re-sync permission on `applicationDidBecomeActive`, since it can change in the
     Settings app. (The bare sample only forwards it once, inside the `requestAuthorization` completion.)
2. application(_:didRegisterForRemoteNotificationsWithDeviceToken:): `listener.tokenUpdated(to: deviceToken)`.
   Optionally cache the hex string in UserDefaults to seed the listener next launch — use ONE shared
   key for both the write here and the seed read in the listener init, or the seed silently breaks.
3. application(_:didFailToRegisterForRemoteNotificationsWithError:): just log — Nugget gets no token this session.
4. userNotificationCenter(_:didReceive:withCompletionHandler:) (TAP): extract the deeplink from
   `response.notification.request.content.userInfo`. It is NESTED two levels under `meta` — not a flat
   top-level key:
       let meta = userInfo["meta"] as? [String: Any]
       let deeplink = meta?["deeplink"] as? String        // NOT userInfo["deeplink"]
   If `deeplink` is nil OR `NuggetFactory.canOpenDeeplink(deeplink:)` is false → fall through to your
   own routing. Otherwise hand the deeplink to your UI layer (the visible / root view controller) to
   build via `factory.contentViewController(deeplink:)` and push/present it — keep the factory call
   OUT of AppDelegate. ALWAYS call the completion handler (e.g. `defer { completionHandler() }`).
5. userNotificationCenter(_:willPresent:withCompletionHandler:) (FOREGROUND): return
   `[.banner, .sound, .badge]`, or `[]` to suppress when the user is already viewing that exact chat.
6. On logout: `factory.resetNuggetSDK { _ in }`.

## FCM (only if the app ALSO uses Firebase Cloud Messaging)
Nugget needs the RAW APNs token, not the FCM token. Add `FirebaseAppDelegateProxyEnabled = NO`
(Boolean) to Info.plist — this is load-bearing, not optional polish: without it Firebase swizzles
your AppDelegate and `didRegisterForRemoteNotificationsWithDeviceToken` may never hand you the raw
token at all. Then in that callback set BOTH: `Messaging.messaging().apnsToken = deviceToken` and
`listener.tokenUpdated(to: deviceToken)`.

## Nugget push payload (the actionable deeplink is meta.deeplink)
```json
{ "aps": { "alert": { "title": "...", "body": "..." }, "interruption-level": "time-sensitive" },
  "meta": { "deeplink": "nugget://unified-support/room?flowType=ticketing&ticketID=1234567" } }
```

## Prerequisites (verify / set up)
- Push Notifications capability enabled (+ Background Modes → Remote notifications for background pushes).
- NuggetSDK integrated; auth/config delegates already provided to `initializeNuggetFactory(...)`.
- APNs key/cert configured on the Nugget backend for the app's bundle id.

## Acceptance criteria
- One listener; the SAME instance is the factory's notificationDelegate.
- Token forwarded on every registration/rotation; permission forwarded on request (and, recommended, on didBecomeActive).
- Tapping a Nugget push opens the correct chat; non‑Nugget pushes fall through to existing routing.
- Foreground Nugget pushes present (or are intentionally suppressed when already in that chat).
- Logout calls resetNuggetSDK. AppDelegate contains no factory work.
````

---

## 3. In-depth documentation

Everything below is collapsed — expand a section only when you need its detail.

> Note: This guide shows the raw `NuggetSDK` calls (`tokenUpdated`, `permissionStatusUpdated`,
> `canOpenDeeplink`). The example app wraps several of them in thin helpers of its own
> (`updateNotificationToken`, `refreshPermissionStatus`, `nuggetDeeplink(in:)`, `getNuggetVC`) — those
> are convenience wrappers around the same SDK API, not different functions.

<details>
<summary><strong>Prerequisites</strong></summary>

- **Push Notifications** capability enabled in your target (Signing & Capabilities).
- **Background Modes → Remote notifications** if you want background/data pushes.
- A configured **APNs key/cert** on the Nugget backend for your app's bundle id
  (e.g. `com.zomato.zync` in the sample payload).
- NuggetSDK integrated and `initializeNuggetFactory(...)` already set up
  (see [`NuggetService.swift`](../NuggetSDKExample/NuggetSDKExample/NuggetSetup/NuggetService.swift)).

</details>

<details>
<summary><strong>How the pieces fit together</strong></summary>

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

**Ownership at a glance.** Both SDK objects are **shared static members of `NuggetService`**:
`NuggetService.notificationListener` (the one listener — **every** APNs token / permission update
flows through it and nowhere else) and `NuggetService.factory` (the one `NuggetFactory`, created
**lazily** on first chat open and wired to that listener, so the forwarded token uploads).
`AppDelegate` owns neither — it forwards APNs updates to the static listener, and on a tapped push
forwards the deeplink to the UI layer to open. Both objects share the app's lifetime, so the
listener never loses its uploader to a screen being torn down.

</details>

<details>
<summary><strong>Step 1 — Create the listener and pass it to the factory</strong></summary>

`NuggetPushNotificationsListener` receives the APNS token and permission status and
**automatically uploads** them to the Nugget backend (via an internal Combine pipeline) whenever
either changes — you never call an "upload" method yourself. Keep **one** listener for the whole
app and pass that **same** instance to the factory as `notificationDelegate`. In the example both
live as static members of `NuggetService`:

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

> Note: The SDK delegate callbacks (auth, theme, fonts, …) need an object, so the example backs them with
> a single private `delegates` instance — see `NuggetService.swift`. Everyone else uses the static
> API: `NuggetService.notificationListener` and `NuggetService.getNuggetVC(deeplink:)`.

> Important: The listener can only upload once a factory is created with it. The factory wires itself in as
> the listener's upload delegate, so a token forwarded *before* any factory exists is held (and
> cached) but not uploaded yet. **Creating a factory is not required up front** — it is built
> **lazily, only when a chat is first opened** (`getNuggetVC(deeplink:)`), and the cached token
> uploads at that point. A normal launch builds no factory. If you specifically want the token
> uploaded at launch, create the factory eagerly wherever your app owns it.

> Note: `notificationDelegate` accepts `nil`: internal Zomato clients pass `nil` (the backend already
> routes their pushes); external clients integrating Nugget for their own support flow pass a real
> listener.

### Listener API reference

| Member | Purpose |
|--------|---------|
| `init(apnsToken: String? = nil, pushNotificationPermissionStatus: UNAuthorizationStatus? = nil)` | Create the listener, optionally seeded with a cached token / status. |
| `tokenUpdated(to newToken: String)` | Update the APNS token from a hex string. |
| `tokenUpdated(to newToken: Data)` | Update the APNS token from the raw `Data` Apple hands you — it is hex‑encoded for you. |
| `permissionStatusUpdated(to: UNAuthorizationStatus)` | Tell Nugget whether the user granted/denied notifications. |

The listener de‑dupes against the last‑uploaded value, so it's safe to call these liberally.

</details>

<details>
<summary><strong>Step 2 — Register for APNs and forward the token and permission</strong></summary>

In `didFinishLaunching`: set the notification‑center delegate, request authorization, forward the
permission status, and `registerForRemoteNotifications()`. Then forward the token from the APNs
callback. The two calls that actually feed Nugget are:

```swift
// In application(_:didRegisterForRemoteNotificationsWithDeviceToken:)
NuggetService.notificationListener.tokenUpdated(to: deviceToken)   // raw Data is hex-encoded for you

// After requesting authorization (recommended: also re-sync on didBecomeActive — it can change in Settings)
UNUserNotificationCenter.current().getNotificationSettings { settings in
    NuggetService.notificationListener.permissionStatusUpdated(to: settings.authorizationStatus)
}
```

Full wiring (delegate, authorization request, registration, persistence) is in
[`AppDelegate.swift`](../NuggetSDKExample/NuggetSDKExample/AppDelegate.swift); the example wraps both
calls as `updateNotificationToken(_:)` / `refreshPermissionStatus()` — listener helpers in
[`NuggetPushNotifications.swift`](../NuggetSDKExample/NuggetSDKExample/NuggetSetup/NuggetPushNotifications.swift).

> Important: Seed and forward. On the very first launch nothing is cached, so the `init(apnsToken:)` seed
> is `nil`; the `tokenUpdated(to:)` call in `didRegister…` is what delivers the token the first time
> and on every later rotation.

</details>

<details>
<summary><strong>Generate the APNs device token (and use FCM alongside)</strong></summary>

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

> Important: APNs tokens are only delivered on a **real device** (and modern Simulators on macOS 13+ with a
> signed‑in Apple ID), and they **rotate** — always forward the latest one.

### Use Firebase Cloud Messaging (FCM) alongside

Nugget needs the **raw APNS device token**, *not* the FCM registration token. If you also use FCM,
disable method swizzling and forward the same raw APNS token to both:

1. Add `FirebaseAppDelegateProxyEnabled = NO` (Boolean) to your **Info.plist**.
2. In `didRegisterForRemoteNotificationsWithDeviceToken`, set both:

```swift
Messaging.messaging().apnsToken = deviceToken                          // keep FCM working
NuggetService.notificationListener.tokenUpdated(to: deviceToken)       // give Nugget the RAW APNS token
```

Firebase's guide on disabling swizzling:
<https://firebase.google.com/docs/cloud-messaging/ios/get-started#disable-swizzling>

</details>

<details>
<summary><strong>The Nugget notification payload</strong></summary>

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
`ticketID=1234567` → open the ticketing conversation for that ticket.

</details>

<details>
<summary><strong>Step 3 — Handle the notification tap (deeplink → chat screen)</strong></summary>

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

> Note: The `canOpenDeeplink` contract — a static method on `NuggetFactory` that returns `true` only when
> the deeplink's **host** is `chat`, `zchat`, or `unified-support`. The sample payload's
> `nugget://unified-support/room?…` ⇒ host `unified-support` ⇒ `true`. The wrapper also exposes a
> free function `isValidNuggetDeeplink(deeplink:)` that does the same check.

</details>

<details>
<summary><strong>Step 4 — Foreground (in‑app) notifications</strong></summary>

For a push that arrives while the app is foregrounded, iOS calls `willPresent`; return the
presentation options. Show the banner normally, or return `[]` to suppress it (e.g. when the user is
already on that exact chat):

```swift
completionHandler([.banner, .sound, .badge])   // show — or [] to suppress
```

The example centralises this decision in a listener helper —
`NuggetService.notificationListener.foregroundPresentationOptions(for:isViewingChat:)`.

> Note: Tapping the foreground banner still routes through `didReceive response` (Step 3), so the deeplink
> handling is shared — `willPresent` only decides whether to *display* the banner.

</details>

<details>
<summary><strong>Clear the token on logout</strong></summary>

When the user logs out, tell Nugget to stop targeting this device:

```swift
NuggetService.factory.resetNuggetSDK { success in print("Nugget token reset: \(success)") }
```

This makes the backend call with the token removed / permission denied, and clears the locally
cached token.

</details>

<details>
<summary><strong>Checklist</strong></summary>

- [ ] Push Notifications capability (+ Background Modes if needed) enabled.
- [ ] `UNUserNotificationCenter.current().delegate = self` set before launch finishes.
- [ ] Exactly one `NuggetPushNotificationsListener` (here `static NuggetService.notificationListener`); the same instance is wired into the factory. **All** APNS token / permission updates go through it — nowhere else. (The factory is built lazily on first chat open — no need to create it up front; the cached token uploads then.)
- [ ] Permission requested; `permissionStatusUpdated(to:)` forwarded to that static listener (recommended: also re‑sync on `didBecomeActive`, since it can change in Settings).
- [ ] `registerForRemoteNotifications()` called after permission granted.
- [ ] `NuggetPushNotificationsListener` created and passed as `notificationDelegate` to `initializeNuggetFactory(...)`.
- [ ] APNS token forwarded via `tokenUpdated(to:)` in `didRegisterForRemoteNotificationsWithDeviceToken`.
- [ ] (FCM only) swizzling disabled; raw APNS token sent to *both* `Messaging` and Nugget.
- [ ] Tap handling: parse `meta.deeplink` → `NuggetFactory.canOpenDeeplink(deeplink:)` → `factory.contentViewController(deeplink:)`.
- [ ] Foreground `willPresent` returns the desired presentation options.
- [ ] Logout calls `factory.resetNuggetSDK(completionHandler:)`.

</details>

<details>
<summary><strong>API quick reference (NuggetSDK wrapper)</strong></summary>

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

</details>
