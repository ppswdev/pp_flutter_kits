#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint audio_engine_player.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'audio_engine_player'
  s.version          = '1.0.0'
  s.summary          = 'Flutter plugin for AudioEnginePlayer, supporting iOS 14+.'
  s.description      = <<-DESC
Flutter plugin for AudioEnginePlayer, supporting iOS 14+.'
                       DESC
  s.homepage         = 'https://github.com/xiaopindev/audio_engine_player'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ppswdev' => 'xiaopn166@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
