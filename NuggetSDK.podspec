Pod::Spec.new do |s|
  s.name             = 'NuggetSDK'
  s.version          = '4.0.0'
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
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.12-Nugget/Nugget.xcframework.zip -o Nugget.xcframework.zip
    verify_checksum "Nugget.xcframework.zip" "fed99759721af418b59e4120057611081a4fdd2de6bfc8472a9c2d000d3c35d8"
    unzip -o Nugget.xcframework.zip
    rm Nugget.xcframework.zip

    echo "Downloading and unzipping NuggetFoundation..."
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.2-Foundation/NuggetFoundation.xcframework.zip -o NuggetFoundation.xcframework.zip
    verify_checksum "NuggetFoundation.xcframework.zip" "bac60616a9c27b2fb2d5564324be369c75d6460238891e7f7163dcafe3516922"
    unzip -o NuggetFoundation.xcframework.zip
    rm NuggetFoundation.xcframework.zip

    echo "Downloading and unzipping NuggetJumbo..."
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.2-Jumbo/NuggetJumbo.xcframework.zip -o NuggetJumbo.xcframework.zip
    verify_checksum "NuggetJumbo.xcframework.zip" "7ba9883d3361002b33d9e093e6b67fabddea03180410f5aedfa3e6ab44e4a83a"
    unzip -o NuggetJumbo.xcframework.zip
    rm NuggetJumbo.xcframework.zip

    echo "Downloading and unzipping ZApiManager..."
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/0.0.2-ApiManager/ZApiManager.xcframework.zip -o ZApiManager.xcframework.zip
    verify_checksum "ZApiManager.xcframework.zip" "722d70d3072629f8a51e99b9e2283047204c694c5a3629640d78b74ff0ce9cbf"
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
