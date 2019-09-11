
Saver migration
===============
The new API for saver allows clients to use saver as an
external file system. This means that saver will no longer
expose a model-like API, eg group_create(), kata_ran_tests().
For a smooth migration, the server has been refactored so that
initially it will still offer these model-like methods, but
implement them by delegating to code in the src/bridge/ dir
which will, in turn, use the new primitive file-system like API.
On the client-side there are multiple versions of client-code.
Again this is intended to help a smooth migration. Specifically,

  v0 - this is code that delegates directly to the model API on the
       server. Viz, this is how clients currently run.

  v1 - this is code that duplicates the server's src/bridge code
       (but on the client side) and thus only relies on the
       server's new file-system like API. The intention is that v0 and v1
       have exactly the same functionality (there are dual-tests
       to verify this) and the client code will initially move
       from v0 to v1. And once the client has migrated from v0 to v1,
       the server will no longer need to support v0, and the src/bridge/
       code can all be deleted.

  v2 - this is a new version of client-side code that is _not_
       compatible with the current v0==v1 schema. It is intended to
       try and ensure that the new file-system like API not only
       allows v1 to mimic v0, but also to allow further migration
       to a faster and more robust schema (for details see the comments
       at the top of test_client/src/[kata|group]_v2.rb ).
       Such a migration will require each session's manifest to store an
       explicit version number. Client-side code will then need
       to handle old and new manifest versions.


--------------------------------------------------------------------------------

- join should return :full not nil

- web can then do batch(read,read) to ready both
  was_files and now_files in one call.

- fix web footer messages for partial degradation (saver,ragger)

- currently if there is saver failure you can end up with
  an events.json file like this... (Saver failed to save 2,3,4,5,6)
    { .... } # 0
    { .... } # 1
    { .... } # 7
  local id with this structure == http://192.168.99.100/kata/edit/NK6ZVS

- Check diff works when there are these saver-offline gaps.

- Keep manifest's version number as data submitted in kata/edit's html form.
  Use that in web to choose group/kata implementations.
  Don't switch version (representation) mid session.
  What about forking? Always fork to latest version?

- zipper downloads will be in a certain format...
  How does that affect coupling?
  Download format(s)?
  0) raw format suitable to xfering to other server
  1) git repo
  2) tgz containing files suitable for use in
     $cyber-dojo start-point create command.
  3) getting a tgz of the current client-side files
     would be good if saver was offline.
