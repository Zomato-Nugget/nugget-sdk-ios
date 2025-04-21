// The Swift Programming Language
import NuggetExternalDependency
import Nugget
import NuggetJumbo

public typealias NuggetFactory = Nugget.ZChatKitFactory

public typealias NuggetAuthUserInfo = Nugget.ZChatAuthUserInfo
public typealias NuggetConversationInfo = Nugget.ZChatConversationInfo

public typealias NuggetAuthProviderDelegate = Nugget.ZChatAuthProviderDelegate
public typealias NuggetThemeProviderDelegate = Nugget.ZChatCustomThemeProviderDelegate
public typealias NuggetFontProviderDelegate = Nugget.ZChatCustomFontProviderDelegate
public typealias NuggetTicketCreationDelegate = Nugget.ZChatTicketCreationHandlerDelegate
public typealias NuggetPushNotificationsListener = Nugget.ZChatPushNotificationsListener

weak private var nuggetFactory: NuggetFactory?

public func initializeNuggetFactory(authDelegate: NuggetAuthProviderDelegate, notificationDelegate: NuggetPushNotificationsListener) -> NuggetFactory {
    let tempNuggetFactory = NuggetFactory(authManagerDelegate: authDelegate, pushNotificationsManager: notificationDelegate)
    nuggetFactory = tempNuggetFactory
    return tempNuggetFactory
}

public func initializeNuggetFactory(authDelegate: NuggetAuthProviderDelegate,
                                    notificationDelegate: NuggetPushNotificationsListener,
                                    customThemeProviderDelegate: NuggetThemeProviderDelegate? = nil,
                                    customFontProviderDelegate: NuggetFontProviderDelegate? = nil,
                                    ticketCreationDelegate: NuggetTicketCreationDelegate? = nil) -> NuggetFactory {
    let tempNuggetFactory = NuggetFactory(authManagerDelegate: authDelegate, pushNotificationsManager: notificationDelegate, customThemeProviderDelegate: customThemeProviderDelegate, customFontProviderDelegate: customFontProviderDelegate, ticketCreationDelegate: ticketCreationDelegate)
    nuggetFactory = tempNuggetFactory
    return tempNuggetFactory
}
