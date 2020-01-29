load( "@io_bazel_rules_docker//lang:image.bzl", "app_layer" )
load( "@io_bazel_rules_docker//container:container.bzl", "container_pull" )
load( "//internal:rules.bzl", "perl_binary" )

def repositories():
    excludes = native.existing_rules().keys()

    if "perl_image_base" not in excludes:
        container_pull(
            name = "perl_image_base",
            registry = "docker.io",
            repository = "library/perl",
            digest = "sha256:13762a970e0527f324d8c8e7de545e5a77479cfac6add43a02dd186140332e73"
        )

def perl_image(name, base = None, deps = [], layers = [], binary = None, **kwargs):
    if layers:
        print("perl_image does not benefit from layers=[], got: %s" % layers)

    if not binary:
        binary = name + ".binary"
        perl_binary(name = binary, deps = deps + layers, **kwargs)
    elif deps:
        fail("kwarg does nothing when binary is specified", "deps")

    if not base:
        base = "@perl_image_base//image"

    app_layer(
        name = name,
        base = base,
        binary = binary,
        directory = '/srv/app',
        visibility = kwargs.get("visibility", None),
        tags = kwargs.get("tags", None),
        args = kwargs.get("args"),
        data = kwargs.get("data"),
        testonly = kwargs.get("testonly"),
    )
