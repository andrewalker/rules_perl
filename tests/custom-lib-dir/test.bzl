load("@bazel_skylib//lib:unittest.bzl", "asserts", "analysistest")
load("//:def.bzl", "perl_library", "PerlInfo")

def _test_impl(ctx):
    env = analysistest.begin(ctx)

    t = analysistest.target_under_test(env)

    asserts.equals(env, ["tests/custom-lib-dir/foo/Single/Library.pm"], [d.short_path for d in t[PerlInfo].transitive_sources.to_list()])
    asserts.equals(env, ["tests/custom-lib-dir/foo"], t[PerlInfo].transitive_lib_dirs.to_list())
    asserts.equals(env, [], t[PerlInfo].transitive_data_files.to_list())

    asserts.equals(env, ["tests/custom-lib-dir/foo/Single/Library.pm"], [d.short_path for d in t[DefaultInfo].files.to_list()])
    asserts.equals(env, ["tests/custom-lib-dir/foo/Single/Library.pm"], [d.short_path for d in t[DefaultInfo].default_runfiles.files.to_list()])

    return analysistest.end(env)

_test = analysistest.make(_test_impl)

def setup_test():
    perl_library(
        name = "custom_lib_dir",
        srcs = ["foo/Single/Library.pm"],
        tags = ["manual"],
        lib_dir = "foo",
    )

    _test(
        name = "test",
        target_under_test = ":custom_lib_dir"
    )
