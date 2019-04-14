Pod::Spec.new do |s|
  s.name         = "OpenSSL-Universal"
  s.version      = "1.0.2.#{("a".."z").to_a.index 'r'}"
  s.summary      = "OpenSSL for iOS and OS X"
  s.description  = "OpenSSL is an SSL/TLS and Crypto toolkit. Deprecated in Mac OS and gone in iOS, this spec gives your project non-deprecated OpenSSL support. Supports OSX and iOS including Simulator (armv7,armv7s,arm64,i386,x86_64)."
  s.homepage     = "http://krzyzanowskim.github.io/OpenSSL/"
  s.license	     = { :type => 'OpenSSL (OpenSSL/SSLeay)', :file => 'LICENSE.txt' }
  s.source       = { :git => "https://github.com/krzyzanowskim/OpenSSL.git", :tag => "#{s.version}" }

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
  
  s.ios.deployment_target = '6.0'
  s.ios.source_files        = 'ios/include/openssl/**/*.h'
  s.ios.public_header_files = 'ios/include/openssl/**/*.h'
  s.ios.header_dir          = 'openssl'
  s.ios.preserve_paths      = 'ios/lib/libcrypto.a', 'ios/lib/libssl.a'
  s.ios.vendored_libraries  = 'ios/lib/libcrypto.a', 'ios/lib/libssl.a'

  s.osx.deployment_target = '10.8'
  s.osx.source_files        = 'macos/include/openssl/**/*.h'
  s.osx.public_header_files = 'macos/include/openssl/**/*.h'
  s.osx.header_dir          = 'openssl'
  s.osx.preserve_paths      = 'macos/lib/libcrypto.a', 'macos/lib/libssl.a'
  s.osx.vendored_libraries  = 'macos/lib/libcrypto.a', 'macos/lib/libssl.a'

  s.requires_arc = false
end
