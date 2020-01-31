load("@bazel_skylib//lib:unittest.bzl", "asserts", "analysistest")
load("//:def.bzl", "perl_library", "PerlInfo")

def _test_impl(ctx):
    env = analysistest.begin(ctx)

    t = analysistest.target_under_test(env)

    asserts.equals(env, ["tests/library-single/lib/Single/Library.pm"], [d.short_path for d in t[PerlInfo].transitive_sources.to_list()])
    asserts.equals(env, ["tests/library-single/lib"], t[PerlInfo].transitive_lib_dirs.to_list())
    asserts.equals(env, [], t[PerlInfo].transitive_data_files.to_list())

    asserts.equals(env, ["tests/library-single/lib/Single/Library.pm"], [d.short_path for d in t[DefaultInfo].files.to_list()])
    asserts.equals(env, ["tests/library-single/lib/Single/Library.pm"], [d.short_path for d in t[DefaultInfo].default_runfiles.files.to_list()])

    return analysistest.end(env)

_test = analysistest.make(_test_impl)

def setup_test():
    perl_library(
        name = "single_library",
        srcs = ["lib/Single/Library.pm"],
        tags = ["manual"],
    )

    _test(
        name = "test",
        target_under_test = ":single_library"
    )
