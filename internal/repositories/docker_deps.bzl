load("@io_bazel_rules_docker//repositories:deps.bzl", _docker_dependencies = "deps")
load(
    "@io_bazel_rules_docker//toolchains/docker:toolchain.bzl",
    _docker_toolchain_configure = "toolchain_configure",
)

def deps():
    _docker_dependencies()

    if "docker_config" not in native.existing_rules().keys():
        # Automatically configure the docker toolchain rule to use the default
        # docker binary from the system path
        _docker_toolchain_configure(name = "docker_config")
