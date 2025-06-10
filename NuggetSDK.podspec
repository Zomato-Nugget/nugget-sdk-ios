Pod::Spec.new do |s|
  s.name             = 'NuggetSDK'
  s.version          = '0.0.10'
  s.summary          = 'The Nugget SDK for iOS.'
  s.description      = <<-DESC
                     A longer description of NuggetSDK.
                     DESC
  s.homepage         = 'https://github.com/Zomato-Nugget/nugget-sdk-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' } # Assuming MIT, create a LICENSE file if you don't have one
  s.author           = { 'Zomato' => 'rajesh.budhiraja@zomato.com' }
  s.source           = { :git => 'https://github.com/Zomato-Nugget/nugget-sdk-ios'}

  s.ios.deployment_target = '14.0'
  s.swift_versions = ['5.0']

  s.source_files = 'Sources/NuggetSDK/**/*.swift'

  # External dependencies
  s.dependency 'JTAppleCalendar', '8.0.5'
  s.dependency 'Alamofire', '~> 5.10.2'
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
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.8-Nugget/Nugget.xcframework.zip -o Nugget.xcframework.zip
    verify_checksum "Nugget.xcframework.zip" "a402dadc9e0159a641c5b7a6adea438c0a3ecd1ccb874f59b32869d4161760bb"
    unzip -o Nugget.xcframework.zip
    rm Nugget.xcframework.zip

    echo "Downloading and unzipping NuggetFoundation..."
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.2-Foundation/NuggetFoundation.xcframework.zip -o NuggetFoundation.xcframework.zip
    verify_checksum "NuggetFoundation.xcframework.zip" "bac60616a9c27b2fb2d5564324be369c75d6460238891e7f7163dcafe3516922"
    unzip -o NuggetFoundation.xcframework.zip
    rm NuggetFoundation.xcframework.zip

    echo "Downloading and unzipping NuggetJumbo..."
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.2-Jumbo/NuggetJumbo.xcframework.zip -o NuggetJumbo.xcframework.zip
    verify_checksum "NuggetJumbo.xcframework.zip" "f948156ca7185014e7a9fde0efb1222a8201e677c51a37ffc94902db06cb1b2d"
    unzip -o NuggetJumbo.xcframework.zip
    rm NuggetJumbo.xcframework.zip

    echo "Downloading and unzipping ZApiManager..."
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.2-ApiManager/ZApiManager.xcframework.zip -o ZApiManager.xcframework.zip
    verify_checksum "ZApiManager.xcframework.zip" "8d2d4cd17a4988a0c68b2950a100d73a2fc3233822ceb4f573cabc6733e58015"
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
