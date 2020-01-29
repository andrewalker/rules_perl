load(":docker_deps.bzl", docker_deps = "deps")
load(":images.bzl", image_deps = "deps")

def deps():
    docker_deps()
    image_deps()
