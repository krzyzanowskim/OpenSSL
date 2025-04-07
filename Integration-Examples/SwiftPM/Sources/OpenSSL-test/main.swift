import OpenSSL

SSL_library_init()
SSL_load_error_strings()
OpenSSL_add_all_algorithms()


let provider = OSSL_PROVIDER_load(nil, "legacy")
print(provider)

print("Hello, world!")
