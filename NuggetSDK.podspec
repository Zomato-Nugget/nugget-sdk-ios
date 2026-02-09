Pod::Spec.new do |s|
  s.name             = 'NuggetSDK'
  s.version          = '4.5.6'
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
    curl -L https://github.com/Zomato-Nugget/nugget-sdk-ios/releases/download/4.5.6-Nugget/Nugget.xcframework.zip -o Nugget.xcframework.zip
    verify_checksum "Nugget.xcframework.zip" "317c4eb6cfea965cc901247e589745416b8077eaa00cfdfff6d50ca4d59bdc39"
    unzip -o Nugget.xcframework.zip
    rm Nugget.xcframework.zip
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
