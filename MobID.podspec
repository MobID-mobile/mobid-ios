#
# Be sure to run `pod lib lint MobID.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MobID'
  s.version          = '0.4.0'
  s.summary          = 'iOS SDK of MobID.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/MobID-mobile/mobid-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'AleksandrPavliuk' => 'pavliuk.aleksandr@gmail.com' }
  s.source           = { :git => 'https://github.com/MobID-mobile/mobid-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.swift_versions = ['4.0', '4.2', '5.0', '5.1']

  s.source_files = 'MobID/Classes/**/*'
  s.resources = 'MobID/Assets/*.{xib,xcassets,png,jpg,otf,ttf}'
  
  # s.resource_bundles = {
  #   'MobID' => ['MobID/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit'

   s.ios.vendored_frameworks = 'Frameworks/WebRTC.xcframework', 'Frameworks/JitsiMeetSDK.xcframework'

   s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
   s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
