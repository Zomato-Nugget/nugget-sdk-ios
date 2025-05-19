# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

# Workspace definition is recommended for local pod development
# workspace 'NuggetSDK.xcworkspace' 

target 'CocoaPodTestApp' do
  use_frameworks!
  
  # Main SDK pod that includes all dependencies
  pod 'NuggetSDK', :path => '.'
  
  # External dependencies
  pod 'ZMarkupParser', :git => 'https://github.com/BudhirajaRajesh/ZMarkupParser.git', :tag => '2.0.6'
  
  project 'CocoaPodTestApp/CocoaPodTestApp.xcodeproj'
end 