#!/usr/bin/ruby

# This script is called using flock like this:
#
#     flock /tmp/1BBAED9A join.rb /a/b/c/1BBAED9A
#
# The first argument is a dir off /tmp which is a local
# file system as required by flock.
#
# The argument to join.rb is a dir which is probably a
# mounted Persistent-Volume-Claim non-local file system.

# It assumes grouper.create(manifest) has saved a children.json file
# in /a/b/c/1BBAED9A which (initially) holds (0..63).to_a.shuffle

require 'json'

my_dir = ARGV[0]
filename = "#{my_dir}/children.json"
unborn = JSON.parse(IO.read(filename))
born = unborn.shift
IO.write(filename, JSON.unparse(unborn))
print born
