#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint opentok_flutter.podspec' to validate before publishing.
#
require 'yaml'
pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
libraryVersion = pubspec['version'].gsub('+', '-')
openTokLibraryVersion = '2.18.0'

Pod::Spec.new do |s|
  s.name             = 'opentok_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Flutter library for OpenTok iOS and Android SDKs'
  s.description      = <<-DESC
Flutter library for OpenTok iOS and Android SDKs
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'FlutterBR' => 'marcelo@flutterbr.dev' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'OpenTok', openTokLibraryVersion
  s.dependency 'SnapKit', '~> 5.0.0'
  s.static_framework = true

  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

  s.prepare_command = <<-CMD
      echo // Generated file, do not edit > Classes/UserAgent.h
      echo "#define LIBRARY_VERSION @\\"#{libraryVersion}\\"" >> Classes/UserAgent.h
      echo "#define LIBRARY_NAME @\\"opentok_flutter\\"" >> Classes/UserAgent.h
      echo "#define OPENTOK_LIBRARY_VERSION @\\"#{openTokLibraryVersion}\\"" >> Classes/UserAgent.h
    CMD
end
