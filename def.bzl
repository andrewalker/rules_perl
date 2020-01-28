load(
    "//internal:rules.bzl",
    _perl_binary = "perl_binary",
    _perl_library = "perl_library",
    _perl_test = "perl_test",
)
load(
    "//internal:providers.bzl",
    _PerlInfo = "PerlInfo",
)

perl_binary  = _perl_binary
perl_library = _perl_library
perl_test    = _perl_test
PerlInfo     = _PerlInfo
