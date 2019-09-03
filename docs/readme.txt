
split-off-singler-and-grouper branch
====================================
- do todos
- fix coverage gaps

Later...
========

- join should return :full not nil

- web can then do batch(read,read) to ready both was_files and now_files in one call.

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

- for k8s
- release new saver with old+new api - ensure Sami is around...
- release new web that uses new api
- drop old api from saver
