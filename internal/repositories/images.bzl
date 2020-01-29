load("@io_bazel_rules_docker//repositories:go_repositories.bzl", _go_deps = "go_deps")
load("//internal:image.bzl", _image_repositories = "repositories")

def deps():
    _go_deps()
    _image_repositories()
