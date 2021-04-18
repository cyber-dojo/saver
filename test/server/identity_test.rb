# frozen_string_literal: true
require_relative 'test_base'

class IdentityTest < TestBase

  def self.hex_prefix
    '1B5'
  end

  # - - - - - - - - - - - - - - - - -

  test '2C6', %w[
  the user running all the server tests has
  uid=19663(saver), gid=65533(nogroup) ] do
    assert_equal %w( saver 19663 ), [user_name,uid]
    assert_equal %w( nogroup 65533 ), [group_name,gid]
  end

  private

  def user_name
    `whoami`.strip
  end

  def group_name
    `getent group #{gid}`.split(':')[0]
  end

  def uid
    `id -u #{user_name}`.strip
  end

  def gid
    `id -g #{user_name}`.strip
  end

end
