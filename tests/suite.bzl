
def perl_test_suite(name):
    native.test_suite(
        name = name,
        tests = [
            "//tests/single-library:test",
            "//tests/multiple-libraries:test",
            "//tests/custom-lib-dir:test",
            "//tests/libraries-with-data:test",
            "//tests/binary-simple:test",
            # ...
        ],
    )
