
split-off-singler-and-grouper branch

- currently if there is saver failure you can end up with
  an events.json file like this... Saver failed to save 2,3
    { .... } # 0
    { .... } # 1
    { .... } # 4
  local id with this structure == http://192.168.99.100/kata/edit/NK6ZVS

- Check diff works when there are these saver-offline gaps.

- Inspect json files on default VM for above updates.
  Keep manifest's version number as data submitted in kata/edit's html form.
  Use that in web to choose group/kata implementations.
  Don't switch version (representation) mid session.

- zipper downloads will be in a certain format...
  How does that affect coupling?

- client uses SaverException (like web)
- fix coverage gaps
- fix todos
- add parallel branch in web repo
- fix web footer messages for partial degradation (saver,ragger)
- try out images on local server and under versioner

- for k8s
- release new saver with old+new api - ensure Sami is around...
- release new web that uses new api
- drop old api from saver
