Pod::Spec.new do |s|
  s.name             = 'NuggetSDK'
  s.version          = '0.1.0' # Replace with your starting version
  s.summary          = 'The Nugget SDK for iOS.'
  s.description      = <<-DESC
                     A longer description of NuggetSDK.
                     DESC
  s.homepage         = 'https://github.com/Zomato-Nugget/nugget-sdk-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' } # Assuming MIT, create a LICENSE file if you don't have one
  s.author           = { 'Your Company' => 'mobile-dev@your_company.com' } # Replace with your author details
  s.source           = { :git => 'https://github.com/Zomato-Nugget/nugget-sdk-ios', :tag => s.version.to_s } # Replace with your git repo

  s.ios.deployment_target = '14.0'
  s.swift_versions = ['5.0']

  s.source_files = 'Sources/NuggetSDK/**/*.swift'

  # External dependencies
  s.dependency 'JTAppleCalendar', '8.0.5'
  s.dependency 'Alamofire', '~> 5.10.2'
  s.dependency 'ZMarkupParser', '~> 2.0.6'
  s.dependency 'Nuke', '10.7.1'
  
  # Download and prepare all required XCFrameworks with checksum verification
  s.prepare_command = <<-CMD
    # Function to verify checksum
    verify_checksum() {
      local file=$1
      local expected=$2
      local actual=$(shasum -a 256 "$file" | cut -d' ' -f1)
      if [ "$actual" != "$expected" ]; then
        echo "Error: Checksum verification failed for $file. Expected: $expected, Actual: $actual"
        exit 1
      fi
    }

    echo "Downloading and unzipping Nugget..."
    curl -L https://github.com/BudhirajaRajesh/NuggetSDK/releases/download/0.0.7-Nugget/Nugget.xcframework.zip -o Nugget.xcframework.zip
    verify_checksum "Nugget.xcframework.zip" "d0b0eafc488ad2cec4c31bc816931e2216fed8a8f1b8bec1ce9d660250679a75"
    unzip -o Nugget.xcframework.zip
    rm Nugget.xcframework.zip

    echo "Downloading and unzipping NuggetFoundation..."
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.1-Foundation/NuggetFoundation.xcframework.zip -o NuggetFoundation.xcframework.zip
    verify_checksum "NuggetFoundation.xcframework.zip" "7173cf9d6b428f9903605ddb53a4376e73adf6dbb60342a3d385d9fb5a7a41b7"
    unzip -o NuggetFoundation.xcframework.zip
    rm NuggetFoundation.xcframework.zip

    echo "Downloading and unzipping NuggetJumbo..."
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.1-Jumbo/NuggetJumbo.xcframework.zip -o NuggetJumbo.xcframework.zip
    verify_checksum "NuggetJumbo.xcframework.zip" "3d31b79dcda091b9ece81a2a76d8b32b6350e539f38202ab5786733ac65202c5"
    unzip -o NuggetJumbo.xcframework.zip
    rm NuggetJumbo.xcframework.zip

    echo "Downloading and unzipping ZApiManager..."
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.1-ApiManager/ZApiManager.xcframework.zip -o ZApiManager.xcframework.zip
    verify_checksum "ZApiManager.xcframework.zip" "7fce6112c32948830046c82ce045590327c8c442a6aee00d7aef773db6f6b0cb"
    unzip -o ZApiManager.xcframework.zip
    rm ZApiManager.xcframework.zip
  CMD

  # Specify all vendored frameworks
  s.vendored_frameworks = [
    'Nugget.xcframework',
    'NuggetFoundation.xcframework',
    'NuggetJumbo.xcframework',
    'ZApiManager.xcframework'
  ]
  
  # If Nugget is a private pod, uncomment and update the following line with the correct source
  # s.dependency 'Nugget', '~> x.y.z'

  # If your SDK has different submodules or requires more complex structure,
  # you might use subspecs.
end 
