load("@bazel_skylib//lib:unittest.bzl", "asserts", "analysistest")
load("//:def.bzl", "perl_binary", "perl_library", "PerlInfo")

def _test_impl(ctx):
    env = analysistest.begin(ctx)

    t = analysistest.target_under_test(env)

    script = "tests/binary-deps/binary.pl"
    wrapper = "tests/binary-deps/some_perl_binary"
    libs = [ "tests/binary-deps/lib/A.pm", "tests/binary-deps/lib/B.pm", "tests/binary-deps/lib/C.pm" ]
    data_files = [
        "tests/binary-deps/data1.txt",
        "tests/binary-deps/data2.txt",
        "tests/binary-deps/data3.txt",
        "tests/binary-deps/share/favicon.ico",
        "tests/binary-deps/share/favicon.png",
    ]

    asserts.equals(env, libs + [script], [ d.short_path for d in t [PerlInfo].transitive_sources.to_list() ])
    asserts.equals(env, ["tests/binary-deps/lib"], t[PerlInfo].transitive_lib_dirs.to_list())
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
        deps = [":C"],
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
