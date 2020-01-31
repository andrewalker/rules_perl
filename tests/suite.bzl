
def perl_test_suite(name):
    native.test_suite(
        name = name,
        tests = [
            "//tests/library-single:test",
            "//tests/library-multiple:test",
            "//tests/library-custom-dir:test",
            "//tests/library-data:test",
            "//tests/binary-simple:test",
            # ...
        ],
    )
