load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//:def.bzl", "PerlInfo", "perl_library")

def _test_impl(ctx):
    env = analysistest.begin(ctx)

    t = analysistest.target_under_test(env)
    libs = [ "tests/library-multiple/lib/A.pm", "tests/library-multiple/lib/B.pm", "tests/library-multiple/lib/C.pm" ]

    asserts.equals(env, libs, [ d.short_path for d in t [PerlInfo].transitive_sources.to_list() ])
    asserts.equals(env, ["tests/library-multiple/lib"], t[PerlInfo].transitive_lib_dirs.to_list())
    asserts.equals(env, [], t[PerlInfo].transitive_data_files.to_list())

    asserts.equals(env, libs, [d.short_path for d in t[DefaultInfo].files.to_list()])
    asserts.equals(env, libs, [d.short_path for d in t[DefaultInfo].default_runfiles.files.to_list()])

    return analysistest.end(env)

_test = analysistest.make(_test_impl)

def setup_test():
    perl_library(
        name = "A",
        srcs = ["lib/A.pm"],
        tags = ["manual"],
    )
    perl_library(
        name = "B",
        srcs = ["lib/B.pm"],
        tags = ["manual"],
        deps = [":A"],
    )
    perl_library(
        name = "C",
        srcs = ["lib/C.pm"],
        tags = ["manual"],
        deps = [":B"],
    )

    _test(
        name = "test",
        target_under_test = ":C",
    )
