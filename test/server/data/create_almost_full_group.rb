# Generates a group with 63 avatars, ready for group-full test

def require_source(file)
  require_relative("../../source/#{file}")
end

require_source 'externals'
require_source 'model'
require_relative 'kata_test_data'
include KataTestData

version = ARGV[0].to_i

# The manifest the tests use, so no start-points service needs to be up.
manifest = manifest_Tennis_refactoring_Python_unitttest
manifest["version"] = version
model = Model.new(Externals.new)

gid = model.group_create(manifest:manifest)
63.times { model.group_join(id:gid) }

print(gid)
