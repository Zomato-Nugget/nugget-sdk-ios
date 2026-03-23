// The Swift Programming Language
import Nugget

public typealias NuggetFactory = Nugget.ZChatKitFactory

public typealias NuggetAuthUserInfo = Nugget.ZChatAuthUserInfo
public typealias NuggetConversationInfo = Nugget.ZChatConversationInfo
public typealias NuggetChatBusinessContext = Nugget.ZChatBusinessContext
public typealias NuggetJumboConfiguration = Nugget.NuggetJumboConfiguration
public typealias NuggetConversationMetaObject = Nugget.ZChatConversationMetaObject
public typealias NuggetPayloadTokenDataObject = Nugget.ZChatPayloadTokenDataObject
public typealias NuggetWindowContentType = Nugget.ZChatWindowContentType
public typealias NuggetConversationFlowType = Nugget.ZChatConversationFlowType

public typealias NuggetAuthProviderDelegate = Nugget.ZChatAuthProviderDelegate
public typealias NuggetThemeProviderDelegate = Nugget.ZChatCustomThemeProviderDelegate
public typealias NuggetFontProviderDelegate = Nugget.ZChatCustomFontProviderDelegate
public typealias NuggetTicketCreationDelegate = Nugget.ZChatTicketCreationHandlerDelegate
public typealias NuggetBusinessContextProviderDelegate = Nugget.ZChatBusinessContextProviderDelegate
public typealias NuggetSDKConfigurationDelegate = Nugget.NuggetSDKConfigurationDelegate
public typealias NuggetPushNotificationsListener = Nugget.ZChatPushNotificationsListener
public typealias NuggetConversationSessionDelegate = Nugget.ZChatConversationSessionDelegate
public typealias NuggetComponentProviderDelegate = Nugget.ZChatComponentProviderDelegate
public typealias NuggetExtraParamProviderDelegate = Nugget.ZChatExtraParamProviderDelegate
public typealias NuggetFontPropertiesMapping = Nugget.FontPropertiesMapping
public typealias NuggetFontWeights = Nugget.NuggetFontWeights
public typealias NuggetFontSizes = Nugget.NuggetFontSizes
public typealias NuggetUserInfo = Nugget.ZChatUserInfo
public typealias NuggetDeeplinkListener = Nugget.ZChatDeeplinkListener
public typealias NuggetLanguage = Nugget.NuggetLanguage
public typealias NuggetMapView = Nugget.ChatMapView
public typealias NuggetMapEventsListener = Nugget.ZChatMapEventsListener
public typealias NuggetColorTheme = Nugget.NuggetColorTheme
public typealias NuggetSurfaceToken = Nugget.NuggetSurfaceToken
public typealias NuggetBorderToken = Nugget.NuggetBorderToken
public typealias NuggetIconToken = Nugget.NuggetIconToken
public typealias NuggetSolidButtonToken = Nugget.NuggetSolidButtonToken
public typealias NuggetOutlinedButtonToken = Nugget.NuggetOutlinedButtonToken
public typealias NuggetTextButtonToken = Nugget.NuggetTextButtonToken
public typealias NuggetDishRatingToken = Nugget.NuggetDishRatingToken
public typealias NuggetStepperPrimaryToken = Nugget.NuggetStepperPrimaryToken
public typealias NuggetStepperSecondaryToken = Nugget.NuggetStepperSecondaryToken
public typealias NuggetCrystalToken = Nugget.NuggetCrystalToken
public typealias NuggetShimmerToken = Nugget.NuggetShimmerToken
public typealias NuggetBrandToken = Nugget.NuggetBrandToken
public typealias NuggetBackgroundToken = Nugget.NuggetBackgroundToken
public typealias NuggetBaseColorToken = Nugget.NuggetBaseColorToken
public typealias NuggetResRatingToken = Nugget.NuggetResRatingToken
public typealias NuggetTextToken = Nugget.NuggetTextToken
public typealias NuggetSDKHelper = Nugget.NuggetSDKHelper
public typealias NuggetViewControllerProtocol = Nugget.ZChatViewControllerProtocol

weak private var nuggetFactory: NuggetFactory?

public func isValidNuggetDeeplink(deeplink: String) -> Bool {
    return NuggetFactory.canOpenDeeplink(deeplink: deeplink)
}

public func initializeNuggetFactory(authDelegate: NuggetAuthProviderDelegate,
                                    sdkConfigurationDelegate: NuggetSDKConfigurationDelegate,
                                    notificationDelegate: NuggetPushNotificationsListener?, // will be nil for internal clients
                                    chatBusinessContextDelegate: NuggetBusinessContextProviderDelegate? = nil,
                                    deeplinkListener: NuggetDeeplinkListener? = nil,
                                    customThemeProviderDelegate: NuggetThemeProviderDelegate? = nil,
                                    customFontProviderDelegate: NuggetFontProviderDelegate? = nil,
                                    ticketCreationDelegate: NuggetTicketCreationDelegate? = nil,
                                    conversationSessionDelegate: NuggetConversationSessionDelegate? = nil,
                                    chatComponentProviderDelegate: NuggetComponentProviderDelegate? = nil,
                                    customHeaderManagerDelegate: NuggetExtraParamProviderDelegate? = nil,
                                    featureFlag: [String : Any] = [:]) -> NuggetFactory {
    let tempNuggetFactory = NuggetFactory(authManagerDelegate: authDelegate,
                                          pushNotificationsManager: notificationDelegate,
                                          nuggetSDKConfigurationDelegate: sdkConfigurationDelegate,
                                          customThemeProviderDelegate: customThemeProviderDelegate,
                                          customFontProviderDelegate: customFontProviderDelegate,
                                          ticketCreationDelegate: ticketCreationDelegate,
                                          chatBusinessContextProviderDelegate: chatBusinessContextDelegate,
                                          deeplinkListener: deeplinkListener,
                                          conversationSessionDelegate: conversationSessionDelegate,
                                          chatComponentProviderDelegate: chatComponentProviderDelegate,
                                          customHeaderManagerDelegate: customHeaderManagerDelegate,
                                          featureFlagDict: featureFlag)
    nuggetFactory = tempNuggetFactory
    return tempNuggetFactory
}
