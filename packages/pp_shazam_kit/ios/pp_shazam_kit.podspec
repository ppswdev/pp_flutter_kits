#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pp_shazam_kit.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pp_shazam_kit'
  s.version          = '1.0.0'
  s.summary          = 'Flutter plugin for ShazamKit, supporting iOS 15+.'
  s.description      = <<-DESC
Flutter plugin for ShazamKit, supporting iOS 15+.'
                       DESC
  s.homepage         = 'https://github.com/ppswdev/pp_flutter_kits/tree/main/packages/pp_shazam_kit'
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
  # s.resource_bundles = {'pp_shazam_kit_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
