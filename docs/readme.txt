
split-off-singler-and-grouper branch

- currently if there is saver failure you can end up with
  an events.json file like this... Saver failed to save the
  traffic-light test runs 2,3
    { .... } # 0
    { .... } # 1
    { .... } # 4
  The dir structure will be...
    .../ID/0/event.json
    .../ID/1/event.json
    .../ID/4/event.json
  But reading back will fail. Eg index == -1
  will do events.lines.size - 1 == 3-1 == 2 but there is no
    .../ID/2/event.json
  Add test for this. Fix this.
  local id with this structure == http://192.168.99.100/kata/edit/NK6ZVS
  Check diff works when there are these saver-offline gaps.

- Inspect json files on default VM for above updates.
  Keep manifest's version number as data submitted in kata/edit's html form.
  Use that to choose group/kata implementations.
  Don't switch version mid session.

- zipper downloads will be in a certain format...
  How does that affect coupling?

- Also prepare new schema that flattens dir structure.
  not .../ID/INDEX/event.json
  but .../ID/INDEX.event.json
  have code and tests for versioning in the manifest.json file.


- fix coverage gaps
- fix todos
- client uses SaverException (like web)
- add parallel branch in web repo
- fix web footer messages for partial degradation (saver,ragger)
- try out images on local server and under versioner

- for k8s
- release new saver with old+new api - ensure Sami is around...
- release new web that uses new api
- drop old api from saver
