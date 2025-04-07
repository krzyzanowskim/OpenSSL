Pod::Spec.new do |s|
  s.name         = "OpenSSL-Universal"
  s.version      = "3.3.3001" # 3.3.3
  s.summary      = "OpenSSL for iOS, macOS, tvOS, visionOS, watchOS"
  s.description  = "OpenSSL is an SSL/TLS and Crypto toolkit. Deprecated in macOS and gone in iOS, this spec gives your project non-deprecated OpenSSL support. Supports macOS, iOS, tvOS, visionOS, watchOS including Simulator (armv7s, arm64, x86_64)."
  s.homepage     = "https://github.com/krzyzanowskim/OpenSSL"
  s.license	     = { :type => 'Apache License, Version 2.0' }
  s.source       = { :http => "https://github.com/krzyzanowskim/OpenSSL/releases/download/#{s.version}/OpenSSL.xcframework.zip", :type => "zip", :flatten => false }

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
  s.ios.deployment_target = "12.0"
  s.osx.deployment_target = "10.15"
  s.tvos.deployment_target = "12.0"
  s.visionos.deployment_target = "1.0"
  s.watchos.deployment_target = "8.0"
  s.vendored_frameworks = "OpenSSL.xcframework"
end
