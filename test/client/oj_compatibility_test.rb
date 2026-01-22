require_relative 'test_base'
require 'json'
require 'oj'

class OjCompatibilityTest < TestBase

  test '93CCB3',
  %w[ Oj.strict_load() is compatible with JSON.parse() ] do
    s = any_hash.to_json
    assert_equal JSON.parse(s), Oj.strict_load(s)
  end

  # - - - - - - - - - - - - - - - - -

  test '93CCB4',
  %w[ Oj.dump() is compatible with JSON.generate() ] do
    o = any_hash
    assert_equal JSON.generate(o), Oj.dump(o)
  end

  # - - - - - - - - - - - - - - - - -

  test '93CCB5',
  %w( Oj.dump() requires strict mode for full JSON.generate() compatibility ) do
    symbol = :image_name
    o = { symbol => 'cyberdojofoundation/python_pytest' }
    Oj.default_options = { mode: :object }
    refute_equal JSON.generate(o), Oj.dump(o)
    assert_equal JSON.generate(o), Oj.dump(o, {mode: :strict})
  end

  # - - - - - - - - - - - - - - - - -

  test '93CCB6',
  %w( Oj setting strict mode as default to simplify dump calls ) do
    symbol = :image_name
    o = { symbol => 'cyberdojofoundation/python_pytest' }
    refute_equal JSON.generate(o), Oj.dump(o)
    Oj.default_options = { mode: :strict }
    assert_equal JSON.generate(o), Oj.dump(o)
  end

  # - - - - - - - - - - - - - - - - -

  test '93CCB7',
  %w[ Oj.generate() requires options to mimic JSON.pretty_generate() ] do
    oj_pretty = Oj.generate(any_hash, {
      :space => ' ',
      :indent => '  ',
      :object_nl => "\n",
      :array_nl => "\n"
    })
    json_pretty = JSON.pretty_generate(any_hash)
    assert_equal oj_pretty, json_pretty
  end

  # - - - - - - - - - - - - - - - - -

  test '93CCB8',
  %w[ Oj.strict_load() throws different exception to JSON.parse() ] do
    not_json = "xxxx{[}]"
    assert_raises(JSON::ParserError) { JSON.parse(not_json) }
    assert_raises(Oj::ParseError) { Oj.strict_load(not_json) }
  end

  private

  def any_hash
    { 'image_name' => 'cyberdojofoundation/gpp_assert:latest',
      'visible_filenames' => [
        'hello.cpp',
        'hello.hpp',
        'cyber-dojo.sh',
        'makefile'
      ],
      'tab_size' => 4
    }
  end

end
