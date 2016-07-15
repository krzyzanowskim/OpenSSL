Pod::Spec.new do |s|
  s.name         = "OpenSSL-Universal"
  s.version      = "1.0.1.#{("a".."z").to_a.index 't'}"
  s.summary      = "OpenSSL for iOS and OS X"
  s.description  = "OpenSSL is an SSL/TLS and Crypto toolkit. Deprecated in Mac OS and gone in iOS, this spec gives your project non-deprecated OpenSSL support. Supports OSX and iOS including Simulator (armv7,armv7s,arm64,i386,x86_64)."
  s.homepage     = "http://krzyzanowskim.github.io/OpenSSL/"
  s.license      = { :type => 'OpenSSL (OpenSSL/SSLeay)', :file => 'LICENSE.txt' }
  s.source       = { :git => "https://github.com/jcavar/OpenSSL.git" }

  s.authors       =  {'Mark J. Cox' => 'mark@openssl.org',
                     'Ralf S. Engelschall' => 'rse@openssl.org',
                     'Dr. Stephen Henson' => 'steve@openssl.org',
                     'Ben Laurie' => 'ben@openssl.org',
                     'Lutz Jänicke' => 'jaenicke@openssl.org',
                     'Nils Larsch' => 'nils@openssl.org',
                     'Richard Levitte' => 'nils@openssl.org',
                     'Bodo Möller' => 'bodo@openssl.org',
                     'Ulf Möller' => 'ulf@openssl.org',
                     'Andy Polyakov' => 'appro@openssl.org',
                     'Geoff Thorpe' => 'geoff@openssl.org',
                     'Holger Reif' => 'holger@openssl.org',
                     'Paul C. Sutton' => 'geoff@openssl.org',
                     'Eric A. Young' => 'eay@cryptsoft.com',
                     'Tim Hudson' => 'tjh@cryptsoft.com',
                     'Justin Plouffe' => 'plouffe.justin@gmail.com'}
  
  s.default_subspec   = 'Static'
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'

  s.subspec 'Static' do |ss|
    ss.ios.deployment_target = '6.0'
    ss.ios.source_files        = 'OpenSSL-iOS/include-ios/openssl/**/*.h'
    ss.ios.public_header_files = 'OpenSSL-iOS/include-ios/openssl/**/*.h'
    ss.ios.header_dir          = 'openssl'
    ss.ios.preserve_paths      = 'OpenSSL-iOS/lib-ios/libcrypto.a', 'OpenSSL-iOS/lib-ios/libssl.a'
    ss.ios.vendored_libraries  = 'OpenSSL-iOS/lib-ios/libcrypto.a', 'OpenSSL-iOS/lib-ios/libssl.a'

    ss.osx.deployment_target = '10.8'
    ss.osx.source_files        = 'OpenSSL-macOS/include-macos/openssl/**/*.h'
    ss.osx.public_header_files = 'OpenSSL-macOS/include-macos/openssl/**/*.h'
    ss.osx.header_dir          = 'openssl'
    ss.osx.preserve_paths      = 'OpenSSL-macOS/lib-macos/libcrypto.a', 'OpenSSL-macOS/lib-macos/libssl.a'
    ss.osx.vendored_libraries  = 'OpenSSL-macOS/lib-macos/libcrypto.a', 'OpenSSL-macOS/lib-macos/libssl.a'

    ss.libraries = 'ssl', 'crypto'
  end

  s.subspec 'Dynamic' do |ss|

    ss.ios.deployment_target = '8.0'
    ss.ios.vendored_frameworks  = 'OpenSSL-iOS/bin/openssl.framework'

    ss.osx.deployment_target = '10.8'
    ss.osx.vendored_frameworks  = 'OpenSSL-macOS/bin/openssl.framework'
  end

  s.requires_arc = false
end
