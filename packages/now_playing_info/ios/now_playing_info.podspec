#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint now_playing_info.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'now_playing_info'
  s.version          = '1.1.0'
  s.summary          = 'A Flutter plugin for managing iOS Now Playing information.'
  s.description      = <<-DESC
A Flutter plugin for managing iOS Now Playing information.
                       DESC
  s.homepage         = 'https://github.com/ppswdev/pp_flutter_kits/tree/main/packages/now_playing_info'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'now_playing_info/Sources/now_playing_info/**/*.swift'
  s.resource_bundles = {'now_playing_info_privacy' => ['now_playing_info/Sources/now_playing_info/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.frameworks = 'MediaPlayer'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

end
