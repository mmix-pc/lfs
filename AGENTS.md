# MMIX LFS project conventions

Maintain formal documentation, code, comments and identifiers in English. Support MMIX only. Keep the root README focused on public setup, configuration, build and launch commands. Record package adaptations and evidence in docs/porting.md. Keep temporary task labels out of public files.

Use GNU Make for public entry points and Bash for host-side scripts. Follow upstream build systems for individual packages. Keep dependencies pinned in manifests. Follow .editorconfig for four-space Bash indentation and tabs in Make recipes. Review scripts with bash -n and ShellCheck where available. Keep these instructions synchronized with build and formatting configuration.

Keep external LLVM, Linux and QEMU inputs read-only. Honor the configured build, output, temporary and shared download directories. Keep working checkouts private to each build and publish shared cache entries under per-entry locks. Package images exclusively from the production rootfs staging directory. Place local planning, experiments, private test source, fixtures and intermediate results in the ignored scratch/ workspace, organized by purpose. Maintain separate development staging and images. Formal files must be usable independently of local development records.

Preserve existing user work and concurrent edits. Discuss material changes to scope, stack, layout or dependencies before proceeding. Stage or commit only under explicit user instruction. Use Conventional Commits. Remote repository creation, pushing and deployment each require an explicit request and authorization.

Obtain specific authorization before network access. Describe the commands or requests, destinations, expected primary and secondary downloads, and effects on disk or execution. Wait for approval and obtain additional authorization for newly discovered destinations or downloads beyond its scope. Continue independent local work while approval is pending.
