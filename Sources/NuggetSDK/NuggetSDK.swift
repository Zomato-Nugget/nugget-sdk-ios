// The Swift Programming Language
import Nugget

public typealias NuggetFactory = Nugget.ZChatKitFactory

public typealias NuggetAuthUserInfo = Nugget.ZChatAuthUserInfo
public typealias NuggetConversationInfo = Nugget.ZChatConversationInfo
public typealias NuggetChatBusinessContext = Nugget.ZChatBusinessContext
public typealias NuggetJumborConfiguration = Nugget.NuggetJumborConfiguration

public typealias NuggetAuthProviderDelegate = Nugget.ZChatAuthProviderDelegate
public typealias NuggetThemeProviderDelegate = Nugget.ZChatCustomThemeProviderDelegate
public typealias NuggetFontProviderDelegate = Nugget.ZChatCustomFontProviderDelegate
public typealias NuggetTicketCreationDelegate = Nugget.ZChatTicketCreationHandlerDelegate
public typealias NuggetBusinessContextProviderDelegate = Nugget.ZChatBusinessContextProviderDelegate
public typealias NuggetSDkConfigurationDelegate = Nugget.NuggetSDkConfigurationDelegate
public typealias NuggetPushNotificationsListener = Nugget.ZChatPushNotificationsListener
public typealias NuggetFontPropertiesMapping = Nugget.FontPropertiesMapping
public typealias NuggetFontWeights = Nugget.NuggetFontWeights
public typealias NuggetFontSizes = Nugget.NuggetFontSizes
public typealias NuggetUserInfo = Nugget.ZChatUserInfo
public typealias NuggetDeeplinkListener = Nugget.ZChatDeeplinkListener

weak private var nuggetFactory: NuggetFactory?

public func initializeNuggetFactory(authDelegate: NuggetAuthProviderDelegate,
                                    notificationDelegate: NuggetPushNotificationsListener,
                                    sdkConfigurationDelegate: NuggetSDkConfigurationDelegate,
                                    chatBusinessContextDelegate: NuggetBusinessContextProviderDelegate? = nil,
                                    deeplinkListener: NuggetDeeplinkListener? = nil,
                                    customThemeProviderDelegate: NuggetThemeProviderDelegate? = nil,
                                    customFontProviderDelegate: NuggetFontProviderDelegate? = nil,
                                    ticketCreationDelegate: NuggetTicketCreationDelegate? = nil) -> NuggetFactory {
    let tempNuggetFactory = NuggetFactory(authManagerDelegate: authDelegate,
                                          pushNotificationsManager: notificationDelegate,
                                          nuggetSDkConfigurationDelegate: sdkConfigurationDelegate,
                                          customThemeProviderDelegate: customThemeProviderDelegate,
                                          customFontProviderDelegate: customFontProviderDelegate,
                                          ticketCreationDelegate: ticketCreationDelegate,
                                          chatBusinessContextProviderDelegate: chatBusinessContextDelegate,
                                          deeplinkListener: deeplinkListener)
    nuggetFactory = tempNuggetFactory
    return tempNuggetFactory
}
