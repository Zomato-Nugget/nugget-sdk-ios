//
//  NuggetService.swift
//  NuggetSDKExample
//
//  Created by Rajesh Budhiraja on 05/06/25.
//

import Foundation
import NuggetSDK
import UIKit

final class NuggetService {
    
    private var pushNotificationPublisher = NuggetPushNotificationsListener(apnsToken: UserDefaults.standard.string(forKey: "deviceToken"))
    
    lazy var factory = initializeNuggetFactory(authDelegate: self,
                                               notificationDelegate: pushNotificationPublisher,
                                               sdkConfigurationDelegate: self,
                                               chatBusinessContextDelegate: self,
                                               deeplinkListener: self,
                                               customThemeProviderDelegate: self,
                                               customFontProviderDelegate: self,
                                               ticketCreationDelegate: self)
    
    func getNuggetVC(deeplink: String) -> UIViewController? {
        factory.contentViewController(deeplink: deeplink)
    }
}

extension NuggetService : NuggetAuthProviderDelegate {
    
    struct NuggetAuthUserInfoImp : NuggetAuthUserInfo {
        var clientID: Int = 1
        var userName: String? = nil
        var userID: String = ""
        var photoURL: String = ""
        var accessToken: String = ""
    }
    
    func authManager(requiresAuthInfo completion: @escaping ((NuggetAuthUserInfo)?, (any Error)?) -> Void) {
        //Make api call to fetch access token or fetch it from cache
        completion(NuggetAuthUserInfoImp(accessToken: "dummy-access-token"), nil)
    }
    func authManager(requestRefreshAuthInfo completion: @escaping ((NuggetAuthUserInfo)?, (any Error)?) -> Void) {
        //Access token is expired. Refresh it and return it.
        completion(NuggetAuthUserInfoImp(accessToken: "dummy-access-token"), nil)
    }
}

extension NuggetService: NuggetSDKConfigurationDelegate {
    func chatScreenClosedCallback() {}
    
    func jumboConfiguration(completion: @escaping (NuggetJumboConfiguration) -> Void) {
        completion(jumboConfiguration())
    }
    
    func jumboConfiguration() -> NuggetJumboConfiguration {
        NuggetJumboConfiguration(nameSpace: "NuggetSDKTest")
    }
}

extension NuggetService: NuggetBusinessContextProviderDelegate {
    struct ChatSupportBusinessContext: NuggetChatBusinessContext {
        var type: String?
        var ticketID: Int?
        var channelHandle: String?
        var ticketGroupingId: String?
        var ticketProperties: [String : [String]]?
        var botProperties: [String : [String]]?
    }
    
    func chatSupportBusinessContext() -> any NuggetChatBusinessContext {
        ChatSupportBusinessContext()
    }
}

extension NuggetService: NuggetThemeProviderDelegate {
    // this will be default color used in sdk for light mode
    var defaultLightModeAccentHexColor: String {
        "#7C8363"
    }
    // this will be default color used in sdk for dark mode
    var defaultDarkModeAccentHexColor: String {
        "#31473A"
    }
    var deviceInterfaceStyle: UIUserInterfaceStyle {
        .unspecified
    }
}

extension NuggetService: NuggetDeeplinkListener {
    func deeplinkInvoked(deeplink: URL?) {
        print("Deeplink triggerred : \(String(describing: deeplink))")
    }
}

extension NuggetService: NuggetTicketCreationDelegate {
    func ticketCreationSucceeded(with conversationID: String) {
        print("Ticket created successfully with conversation ID : \(conversationID)")
    }
    
    func ticketCreationFailed(withError errorMessage: String?) {
        print(errorMessage ?? "Ticket creation failed")
    }
}

extension NuggetService: NuggetFontProviderDelegate {
    
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
    
    var customFontMapping: (any NuggetFontPropertiesMapping)? {
        CustomFontMap()
    }
}
