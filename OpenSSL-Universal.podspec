Pod::Spec.new do |s|
  s.name         = "OpenSSL-Universal"
  s.version      = "3.1.5006" # 3.1.5
  s.summary      = "OpenSSL for iOS, macOS, tvOS, visionOS"
  s.description  = "OpenSSL is an SSL/TLS and Crypto toolkit. Deprecated in macOS and gone in iOS, this spec gives your project non-deprecated OpenSSL support. Supports macOS, iOS, tvOS, visionOS including Simulator (armv7,armv7s,arm64,x86_64)."
  s.homepage     = "https://github.com/krzyzanowskim/OpenSSL"
  s.license	     = { :type => 'Apache License, Version 2.0', :file => 'LICENSE.txt' }
  s.source       = { :http => "https://github.com/krzyzanowskim/OpenSSL/archive/00c7a4195a7006bf9426c74f15c4a88a661d353d.zip", :type => "zip", :flatten => true }

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
  s.vendored_frameworks = "Frameworks/OpenSSL.xcframework"
end
