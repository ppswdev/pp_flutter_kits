#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pp_asa_attribution.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pp_asa_attribution'
  s.version          = '1.1.0'
  s.summary          = 'Flutter plugin for Apple Search Ads Attribution, supporting iOS 15.0+.'
  s.description      = <<-DESC
Flutter plugin for Apple Search Ads Attribution, supporting iOS 15.0+.'
                       DESC
  s.homepage         = 'https://github.com/ppswdev/pp_flutter_kits/tree/main/packages/pp_asa_attribution'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ppswdev' => 'xiaopin166@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'pp_asa_attribution/Sources/pp_asa_attribution/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  s.resource_bundles = {
    'pp_asa_attribution_privacy' => ['pp_asa_attribution/Sources/pp_asa_attribution/PrivacyInfo.xcprivacy']
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

end
