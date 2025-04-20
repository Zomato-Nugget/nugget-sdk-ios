// The Swift Programming Language
// https://docs.swift.org/swift-book
import NuggetExternalDependency
import NuggetInternalDependency
import Nugget

public typealias NuggetAuthUserInfo = Nugget.ZChatAuthUserInfo
public typealias NuggetConversationInfo = Nugget.ZChatConversationInfo
public typealias NuggetFactory = Nugget.ZChatKitFactory
public typealias NuggetAuthProviderDelegate = Nugget.ZChatAuthProviderDelegate

public class NuggetSDK {
    public static let shared = NuggetSDK()
    private init() {}
    
    // Add your wrapper methods here that use both dependencies
    public func initialize() {}
}
