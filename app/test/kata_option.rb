# frozen_string_literal: true
require_relative 'test_base'

class KataOptionTest < TestBase

  def self.id58_prefix
    'Ks3'
  end

  def id58_setup
    @id = kata_create(custom_manifest, default_options)
  end

  attr_reader :id

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '460', %w(
  |kata_option_get('theme') defaults to 'light' as that is better on projectors
  ) do
    assert_equal 'light', kata_option_get(id, 'theme')
  end

  versions_test '461', %w(
  |kata_option_set('theme', dark|light) sets the theme option
  |kata_option_get('theme') gets the theme option
  ) do
    kata_option_set(id, 'theme', 'dark')
    assert_equal 'dark', kata_option_get(id, 'theme')
    kata_option_set(id, 'theme', 'light')
    assert_equal 'light', kata_option_get(id, 'theme')
  end

  versions_test '462', %w(
  kata_option_set('theme', not-dark-not-light) raises
  ) do
    assert_raises { kata_option_set(id, 'theme', 'grey') }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '560', %w(
  |kata_option_get('colour') defaults to 'on'
  ) do
    assert_equal 'on', kata_option_get(id, 'colour')
  end

  versions_test '561', %w(
  |kata_option_set('colour', on|off) sets the colour option
  |kata_option_get('colour') gets the colour option
  ) do
    kata_option_set(id, 'colour', 'on')
    assert_equal 'on', kata_option_get(id, 'colour')
    kata_option_set(id, 'colour', 'off')
    assert_equal 'off', kata_option_get(id, 'colour')
  end

  versions_test '562', %w(
  kata_option_set('colour', not-on-not-off) raises
  ) do
    assert_raises { kata_option_set(id, 'colour', 'blue') }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '660', %w(
  |kata_option_get('predict') defaults to 'off'
  ) do
    assert_equal 'off', kata_option_get(id, 'predict')
  end

  versions_test '661', %w(
  |kata_option_set('predict', on|off) sets the predict option
  |kata_option_get('predict') gets the predict option
  ) do
    kata_option_set(id, 'predict', 'on')
    assert_equal 'on', kata_option_get(id, 'predict')
    kata_option_set(id, 'predict', 'off')
    assert_equal 'off', kata_option_get(id, 'predict')
  end

  versions_test '662', %w(
  kata_option_set('predict', not-on-not-off) raises
  ) do
    assert_raises { kata_option_set(id, 'predict', 'maybe') }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '760', %w(
  |kata_option_get('revert') defaults to 'off'
  ) do
    assert_equal 'off', kata_option_get(id, 'revert_red')
    assert_equal 'off', kata_option_get(id, 'revert_amber')
    assert_equal 'off', kata_option_get(id, 'revert_green')
  end

  versions_test '761', %w(
  |kata_option_set('revert', on|off) sets the revert option
  |kata_option_get('revert') gets the revert option
  ) do
    kata_option_set(id, 'revert_red', 'on')
    assert_equal 'on', kata_option_get(id, 'revert_red')
    kata_option_set(id, 'revert_red', 'off')
    assert_equal 'off', kata_option_get(id, 'revert_red')

    kata_option_set(id, 'revert_amber', 'on')
    assert_equal 'on', kata_option_get(id, 'revert_amber')
    kata_option_set(id, 'revert_amber', 'off')
    assert_equal 'off', kata_option_get(id, 'revert_amber')

    kata_option_set(id, 'revert_green', 'on')
    assert_equal 'on', kata_option_get(id, 'revert_green')
    kata_option_set(id, 'revert_green', 'off')
    assert_equal 'off', kata_option_get(id, 'revert_green')
  end

  versions_test '762', %w(
  kata_option_set('revert', not-on-not-off) raises
  ) do
    assert_raises { kata_option_set(id, 'revert_red'  , 'maybe') }
    assert_raises { kata_option_set(id, 'revert_amber', 'maybe') }
    assert_raises { kata_option_set(id, 'revert_green', 'maybe') }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test '860', %w(
  kata_option_get(unknown key) raises
  ) do
    assert_raises { kata_option_get(id, 'salmon') }
    assert_raises { kata_option_get(id, 'revert_blue') }
  end

  versions_test '861', %w(
  kata_option_set(unknown key) raises
  ) do
    assert_raises { kata_option_set(id, 'salmon', 'atlantic') }
    assert_raises { kata_option_set(id, 'revert_blue', 'atlantic') }
  end

end
