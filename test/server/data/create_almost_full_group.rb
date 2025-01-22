# Generates a group with 63 avatars, ready for group-full test

def require_source(file)
  require_relative("../../#{file}")
end

require_source 'externals'
require_source 'model'
require_source 'external/custom_start_points'

version = ARGV[0].to_i

custom = External::CustomStartPoints.new
name = custom.display_names[0]
manifest = custom.manifest(name)
manifest["version"] = version
model = Model.new(Externals.new)

gid = model.group_create(manifests:[manifest], options:{})
63.times { model.group_join(id:gid) }

print(gid)
