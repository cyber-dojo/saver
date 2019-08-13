
The branch split-off-singler-and-grouper
is to...

- split off saver so it contains just the services of external_disk,
  namely
    def exist?(name)
    def make(name)
    def append(filename, content)
    def write(filename, content)
    def read(arg)

- create a new service called grouper exposing grouper.rb
- create a new service called katas exposing singler.rb

- drop unneeded functionality
  eg when returning json in the http body
  check it return what was read directly.
  Avoid reading the file, json parsing it, then
  doing json.fast_generate() to get a string for the http body
