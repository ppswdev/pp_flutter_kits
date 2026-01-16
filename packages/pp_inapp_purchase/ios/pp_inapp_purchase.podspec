#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pp_inapp_purchase.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pp_inapp_purchase'
  s.version          = '1.1.0'
  s.summary          = 'Flutter in-app purchase plugin, supporting iOS (StoreKit2) , providing a unified API interface to manage in-app purchase functionality.'
  s.description      = <<-DESC
Flutter in-app purchase plugin, supporting iOS (StoreKit2) , providing a unified API interface to manage in-app purchase functionality.
                       DESC
  s.homepage         = 'https://github.com/ppswdev/pp_flutter_kits/tree/main/packages/pp_inapp_purchase'  
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ppswdev' => 'xiaopin166@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'inapp_purchase_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
