Pod::Spec.new do |s|
  s.name         = "OpenSSL-Universal"
  s.version      = "1.0.2.#{("a".."z").to_a.index 't'}"
  s.summary      = "OpenSSL for iOS and OS X"
  s.description  = "OpenSSL is an SSL/TLS and Crypto toolkit. Deprecated in Mac OS and gone in iOS, this spec gives your project non-deprecated OpenSSL support. Supports OSX and iOS including Simulator (armv7,armv7s,arm64,x86_64)."
  s.homepage     = "https://github.com/krzyzanowskim/OpenSSL"
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

  s.requires_arc = false
  s.default_subspec = 'Static'
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.9'

  s.subspec 'Static' do |sp|
    sp.ios.deployment_target = '6.0'
    sp.ios.source_files        = 'ios/include/openssl/**/*.h'
    sp.ios.public_header_files = 'ios/include/openssl/**/*.h'
    sp.ios.header_dir          = 'openssl'
    sp.ios.preserve_paths      = 'ios/lib/libcrypto.a', 'ios/lib/libssl.a'
    sp.ios.vendored_libraries  = 'ios/lib/libcrypto.a', 'ios/lib/libssl.a'

    sp.osx.deployment_target = '10.9'
    sp.osx.source_files        = 'macos/include/openssl/**/*.h'
    sp.osx.public_header_files = 'macos/include/openssl/**/*.h'
    sp.osx.header_dir          = 'openssl'
    sp.osx.preserve_paths      = 'macos/lib/libcrypto.a', 'macos/lib/libssl.a'
    sp.osx.vendored_libraries  = 'macos/lib/libcrypto.a', 'macos/lib/libssl.a'
  end

  s.subspec 'Framework' do |sp|
    sp.ios.deployment_target = '8.0'
    sp.ios.vendored_frameworks = 'Frameworks/ios/OpenSSL.framework'
    sp.osx.deployment_target = '10.9'
    sp.osx.vendored_frameworks = 'Frameworks/macos/OpenSSL.framework'
  end
end
