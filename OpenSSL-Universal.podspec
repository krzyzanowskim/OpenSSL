Pod::Spec.new do |s|
  s.name         = "OpenSSL-Universal"
  s.version      = "1.1.1#{("a".."z").to_a.index 'h'}"
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
                   
  s.requires_arc = true
  s.cocoapods_version = '>= 1.9'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.vendored_frameworks = 'Frameworks/OpenSSL.xcframework'

  # Temporary workaround for CocoaPods machinery
  # s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
  # s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
end
