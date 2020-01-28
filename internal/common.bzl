perl_file_types = [".pl",".pm",".pod",".psgi"]

# shamelessly copied from dropbox/dbx_build_tools git repo, bazel/runfiles.*
runfiles_attrs = {
    "_runfiles_template": attr.label(
        default = Label("//internal:runfiles.tmpl"),
        allow_single_file = True,
    ),
}

def write_runfiles_tmpl(ctx, out, content):
    ctx.actions.expand_template(
        template = ctx.file._runfiles_template,
        output = out,
        substitutions = {
            "{workspace_name}": ctx.workspace_name,
            "{content}": content,
        },
        is_executable = True,
    )
