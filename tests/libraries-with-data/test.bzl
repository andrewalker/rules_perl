load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//:def.bzl", "PerlInfo", "perl_library")

def _test_impl(ctx):
    env = analysistest.begin(ctx)

    t = analysistest.target_under_test(env)
    libs = [ "tests/libraries-with-data/lib/A.pm", "tests/libraries-with-data/lib/B.pm", "tests/libraries-with-data/lib/C.pm" ]
    data_files = [
        "tests/libraries-with-data/data1.txt",
        "tests/libraries-with-data/data2.txt",
        "tests/libraries-with-data/data3.txt",
        "tests/libraries-with-data/share/favicon.ico",
        "tests/libraries-with-data/share/favicon.png",
    ]

    asserts.equals(env, libs, [ d.short_path for d in t [PerlInfo].transitive_sources.to_list() ])
    asserts.equals(env, ["tests/libraries-with-data/lib"], t[PerlInfo].transitive_lib_dirs.to_list())
    asserts.equals(env, data_files, [ d.short_path for d in t[PerlInfo].transitive_data_files.to_list() ])

    asserts.equals(env, libs + data_files, [d.short_path for d in t[DefaultInfo].files.to_list()])
    asserts.equals(env, libs + data_files, [d.short_path for d in t[DefaultInfo].default_runfiles.files.to_list()])

    return analysistest.end(env)

_test = analysistest.make(_test_impl)

def setup_test():
    perl_library(
        name = "A",
        srcs = ["lib/A.pm"],
        data = ["data1.txt", "data2.txt", "data3.txt"],
        tags = ["manual"],
    )
    perl_library(
        name = "B",
        srcs = ["lib/B.pm"],
        data = ["share/favicon.ico"],
        tags = ["manual"],
        deps = [":A"],
    )
    perl_library(
        name = "C",
        srcs = ["lib/C.pm"],
        data = ["share/favicon.png"],
        tags = ["manual"],
        deps = [":B"],
    )

    _test(
        name = "test",
        target_under_test = ":C",
    )
