
split-off-singler-and-grouper branch

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
