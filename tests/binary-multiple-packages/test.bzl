load("@bazel_skylib//lib:unittest.bzl", "asserts", "analysistest")
load("//:def.bzl", "perl_binary", "perl_library", "PerlInfo")

def _test_impl(ctx):
    env = analysistest.begin(ctx)

    t = analysistest.target_under_test(env)

    script = "tests/binary-multiple-packages/binary.pl"
    wrapper = "tests/binary-multiple-packages/some_perl_binary"
    libs = [
        "tests/binary-multiple-packages/lib/A.pm",
        "tests/binary-multiple-packages/lib/B.pm",
        "tests/binary-multiple-packages/lib/C.pm",
        "tests/library-data/lib/A.pm"
    ]
    data_files = [
        "tests/binary-multiple-packages/data1.txt",
        "tests/binary-multiple-packages/data2.txt",
        "tests/binary-multiple-packages/data3.txt",
        "tests/binary-multiple-packages/share/favicon.ico",
        "tests/binary-multiple-packages/share/favicon.png",
        "tests/library-data/data1.txt",
        "tests/library-data/data2.txt",
        "tests/library-data/data3.txt",
    ]

    asserts.equals(env, libs + [script], [ d.short_path for d in t [PerlInfo].transitive_sources.to_list() ])
    asserts.equals(env, ["tests/binary-multiple-packages/lib", "tests/library-data/lib"], t[PerlInfo].transitive_lib_dirs.to_list())
    asserts.equals(env, data_files, [ d.short_path for d in t[PerlInfo].transitive_data_files.to_list() ])

    asserts.equals(env, libs + [script] + data_files, [d.short_path for d in t[DefaultInfo].files.to_list()])
    asserts.equals(env, libs + [script] + data_files + [wrapper], [d.short_path for d in t[DefaultInfo].default_runfiles.files.to_list()])

    asserts.equals(env, wrapper, t[DefaultInfo].files_to_run.executable.short_path)
    asserts.false(env, t[DefaultInfo].files_to_run.executable.is_source)

    return analysistest.end(env)

_test = analysistest.make(_test_impl)

def setup_test():
    perl_binary(
        name = "some_perl_binary",
        srcs = ["binary.pl"],
        main = "binary.pl",
        deps = [":C", "//tests/library-data:A"],
        tags = ["manual"],
    )

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
        target_under_test = ":some_perl_binary"
    )
