
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
  Fix this.

- Also prepare new schema that flattens dir structure.
  not .../ID/INDEX/event.json
  but .../ID/INDEX.event.json
  have code and tests for versioning in the manifest.json file.

- fix coverage gaps
- kata.create(starter.manifest) has same race-condition
- fix todos
- client uses SaverException (like web)
- use fast JSON eg Oj
- add parallel branch in web repo
- create SaverFake class in web repo for use in tests
- fix messages for partial web degradation (saver,ragger)
- try out images on local server and under versioner

- for k8s
- release new saver with old+new api - ensure Sami is around...
- release new web that uses new api
- drop old api from saver
