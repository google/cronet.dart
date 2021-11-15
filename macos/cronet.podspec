#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cronet.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cronet'
  s.version          = '0.0.6'
  s.summary          = 'Experimental Cronet dart bindings.'
  s.description      = <<-DESC
  Experimental Cronet dart bindings.
                       DESC
  s.homepage         = 'https://pub.dev/packages/cronet'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Google LLC' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
