
PerlInfo = provider(
    doc = "Encapsulates information provided by the Perl rules.",
    fields = {
        "transitive_lib_dirs": "A depset of lib dirs appearing in the target's lib_dir and the lib_dir of the target's transitive deps.",
        "transitive_sources": "A depset of perl files appearing in the target's srcs and the srcs of the target's transitive deps.",
        "transitive_data_files": "A depset of data files appearing in the target's data and the data of the target's transitive deps.",
    },
)
