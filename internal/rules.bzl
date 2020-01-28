load(":common.bzl", "runfiles_attrs", "write_runfiles_tmpl", "perl_file_types")
load(":providers.bzl", "PerlInfo")

def _perl_binary_impl(ctx):
    trans_srcs_deps = [
       dep[PerlInfo].transitive_sources for dep in ctx.attr.deps
    ]
    trans_srcs = depset(
        direct = ctx.files.srcs,
        transitive = trans_srcs_deps,
    )
    trans_data_deps = [
       dep[PerlInfo].transitive_data_files for dep in ctx.attr.deps
    ]
    trans_data = depset(
        direct = ctx.files.data,
        transitive = trans_data_deps,
    )
    trans_lib_deps = [
       dep[PerlInfo].transitive_lib_dirs for dep in ctx.attr.deps
    ]
    trans_lib = depset(
        transitive = trans_lib_deps,
    )


    wrapper = ctx.outputs.executable
    wrapper_content = "exec perl {perl_script} {extra_args}"

    inner_wrapper = ctx.actions.declare_file(
        ctx.label.name + '.pl',
        sibling = wrapper
    )
    inner_wrapper_content = """
use strict;
use warnings;
use Cwd qw(cwd abs_path);
push @INC, map "$ENV{{RUNFILES}}/$_", split "\\0", "{incs}";

# ooh, I'm feeling dirty :D
my $script = $0 = abs_path(cwd . "/{perl_script}");

do $script or die $@;
"""
    ctx.actions.write(inner_wrapper, inner_wrapper_content.format(perl_script = ctx.file.main.short_path, incs = "\0".join(trans_lib.to_list()) ))

    write_runfiles_tmpl(
        ctx,
        wrapper,
        wrapper_content.format(perl_script = inner_wrapper.short_path, extra_args = " ".join(getattr(ctx.attr, 'extra_args')) ),
    )

    all_files = [inner_wrapper] + trans_srcs.to_list() + trans_data.to_list()

    return [
        PerlInfo(
            transitive_sources    = trans_srcs,
            transitive_data_files = trans_data,
            transitive_lib_dirs   = trans_lib,
        ),
        DefaultInfo(
            files = depset(all_files),
            runfiles = ctx.runfiles( files = all_files ),
        ),
    ]

def _perl_library_impl(ctx):
    trans_srcs_deps = [
       dep[PerlInfo].transitive_sources for dep in ctx.attr.deps
    ]
    trans_srcs = depset(
        direct = ctx.files.srcs,
        transitive = trans_srcs_deps,
    )
    trans_data_deps = [
       dep[PerlInfo].transitive_data_files for dep in ctx.attr.deps
    ]
    trans_data = depset(
        direct = ctx.files.data,
        transitive = trans_data_deps,
    )
    trans_lib_deps = [
       dep[PerlInfo].transitive_lib_dirs for dep in ctx.attr.deps
    ]
    trans_lib = depset(
        direct = ['/'.join([ctx.label.package, ctx.attr.lib_dir])],
        transitive = trans_lib_deps,
    )

#   required_parcels = collect_required_parcels(ctx.attr.deps)
    all_files = trans_srcs.to_list() + trans_data.to_list()

    return [
        PerlInfo(
            transitive_sources    = trans_srcs,
            transitive_data_files = trans_data,
            transitive_lib_dirs   = trans_lib,
        ),
        DefaultInfo(
            files = depset(all_files),
            runfiles = ctx.runfiles( files = all_files ),
        ),
    ]

_perl_binary_attrs = {
    "main":       attr.label(allow_single_file = perl_file_types),
    "srcs":       attr.label_list(allow_files = perl_file_types),
    "deps":       attr.label_list(providers = [[PerlInfo]]),
    "data":       attr.label_list(allow_files = True),
    "extra_args": attr.string_list(),
}

_perl_library_attrs = {
    "srcs":    attr.label_list(allow_files = perl_file_types),
    "deps":    attr.label_list(providers = [[PerlInfo]]),
    "data":    attr.label_list(allow_files = True),
    "lib_dir": attr.string( default = "lib" ),
}

_perl_test_attrs = dict(_perl_binary_attrs);
_perl_test_attrs.update({
    "main": attr.label(allow_single_file = perl_file_types + [".t"]),
    "srcs": attr.label_list(allow_files = perl_file_types + [".t"]),
})

_perl_binary_attrs.update(runfiles_attrs)
_perl_library_attrs.update(runfiles_attrs)
_perl_test_attrs.update(runfiles_attrs)

perl_binary = rule(
    implementation = _perl_binary_impl,
    attrs = _perl_binary_attrs,
    provides = [PerlInfo],
    executable = True,
)

perl_test = rule(
    implementation = _perl_binary_impl,
    attrs = _perl_test_attrs,
    provides = [PerlInfo],
    executable = True,
    test = True,
)

perl_library = rule(
    implementation = _perl_library_impl,
    attrs = _perl_library_attrs,
    provides = [PerlInfo],
)
