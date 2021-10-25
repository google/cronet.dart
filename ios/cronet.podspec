#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cronet.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cronet'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*', '../../*.{h,cc}'
  s.public_header_files = 'Classes/**/*.h', '../../src/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  
  s.vendored_libraries = 'lib/libwrapper.a'
  s.vendored_frameworks = 'lib/Cronet.framework'
  s.libraries = 'wrapper','c++','resolv'
  s.frameworks = 'SystemConfiguration'
  
  s.user_target_xcconfig = { 'OTHER_LDFLAGS' => '-framework Cronet -ObjC -all_load' }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
