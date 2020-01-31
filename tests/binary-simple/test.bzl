load("@bazel_skylib//lib:unittest.bzl", "asserts", "analysistest")
load("//:def.bzl", "perl_binary", "PerlInfo")

def _test_impl(ctx):
    env = analysistest.begin(ctx)

    t = analysistest.target_under_test(env)

    asserts.equals(env, ["tests/binary-simple/script.pl"], [d.short_path for d in t[PerlInfo].transitive_sources.to_list()])
    asserts.equals(env, [], t[PerlInfo].transitive_lib_dirs.to_list())
    asserts.equals(env, [], t[PerlInfo].transitive_data_files.to_list())

    asserts.equals(env, ["tests/binary-simple/script.pl"], [d.short_path for d in t[DefaultInfo].files.to_list()])
    asserts.equals(env, ["tests/binary-simple/script.pl", "tests/binary-simple/my_perl_binary"], [d.short_path for d in t[DefaultInfo].default_runfiles.files.to_list()])

    asserts.equals(env, "tests/binary-simple/my_perl_binary", t[DefaultInfo].files_to_run.executable.short_path)
    asserts.false(env, t[DefaultInfo].files_to_run.executable.is_source)

    return analysistest.end(env)

_test = analysistest.make(_test_impl)

def setup_test():
    perl_binary(
        name = "my_perl_binary",
        srcs = ["script.pl"],
        main = "script.pl",
        tags = ["manual"],
    )

    _test(
        name = "test",
        target_under_test = ":my_perl_binary"
    )
