
The branch split-off-singler-and-grouper
is to...

- split off saver so it contains just the services of external_disk,
  namely
    def exists?(name)
    def make(name)
    def write(filename, content)
    def append(filename, content)
    def read(filename)
    def read_batch(filenames)

- use fast JSON eg Oj

- think about simplifying make?(key)
  it currently checks the dir does not exist
  would it be better if not tied to disk storage as implementation?
  The major make?(key) functionality is in group.join()
  which does this...
   commands = indexes.map { |new_index| make_cmd(id, new_index) }
   make_results = saver.batch_until_true(commands)
