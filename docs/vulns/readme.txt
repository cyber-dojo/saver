CVE Assessment: cyber-dojo saver image
Generated: 2026-07-12

Each vulnerability has its own file in this directory named after its CVE or Snyk ID.

== Saver security posture ==

Saver is an internal cyber-dojo microservice that stores kata data as git repos
on disk. It is not directly internet-facing and runs no user-supplied code.
Runs as UID 19663 (non-root, non-privileged; no shell, no home dir)
git is used only for local repository operations (clone from ".", ref updates);
saver performs no DNS resolution through git/libcurl/c-ares.

== Summary table ==

CVE / ID            Package                    Score  Exploitable?  Reason
--------------------------------------------------------------------------------
CVE-2026-33630      c-ares (via git->libcurl)  7.5    No   c-ares DNS path unreached; saver's git use is local-only. No fix in Alpine v3.24 yet.
