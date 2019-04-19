
/* opensslconf.h */
#if defined(__APPLE__) && defined (__x86_64__)
# include <OpenSSL/opensslconf-x86_64.h>
#endif

#if defined(__APPLE__) && defined (__arm__) && defined (__ARM_ARCH_7A__)
# include <OpenSSL/opensslconf-armv7.h>
#endif

#if defined(__APPLE__) && defined (__arm__) && defined (__ARM_ARCH_7S__)
# include <OpenSSL/opensslconf-armv7s.h>
#endif

#if defined(__APPLE__) && (defined (__arm64__) || defined (__aarch64__))
# include <OpenSSL/opensslconf-arm64.h>
#endif

