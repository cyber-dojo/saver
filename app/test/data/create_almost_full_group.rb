# Generates a group with 63 avatars, ready for group-full test

def require_source(file)
  require_relative("../../source/#{file}")
end
def require_test(file)
  require_relative("../#{file}")
end

require_source 'externals'
require_source 'model'
require_test 'external/custom_start_points'

version = ARGV[0].to_i

custom = External::CustomStartPoints.new
name = custom.display_names[0]
manifest = custom.manifest(name)
model = Model.new(Externals.new)
manifests = [manifest]
options = {}
gid = model.group_create(manifests:manifests, options:options)
63.times { model.group_join(id:gid) }

print(gid)
