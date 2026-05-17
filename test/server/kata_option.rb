require_relative 'test_base'

class KataOptionTest < TestBase

  version_test 2, 'Ks3460', %w(
  | kata_option_get('theme') defaults to 'light' as that is better on projectors
  ) do
    in_kata do |id|
      assert_equal 'light', kata_option_get(id, 'theme')
    end
  end

  versions_01_test 'Ks3469', %w(
  | kata_option_get('theme') defaults to 'light' on pre-existing v0/v1 kata
  ) do
    kids = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    assert_equal 'light', kata_option_get(kids[version], 'theme')
  end

  version_test 2, 'Ks3461', %w(
  | kata_option_set('theme', dark|light) sets the theme option
  | kata_option_get('theme') gets the theme option
  ) do
    in_kata do |id|
      kata_option_set(id, 'theme', 'dark')
      assert_equal 'dark', kata_option_get(id, 'theme')
      kata_option_set(id, 'theme', 'light')
      assert_equal 'light', kata_option_get(id, 'theme')
    end
  end

  version_test 2, 'Ks3462', %w(
  | kata_option_set('theme', not-dark-not-light) raises
  ) do
    in_kata do |id|
      assert_raises { kata_option_set(id, 'theme', 'grey') }
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Ks3560', %w(
  | kata_option_get('colour') defaults to 'on'
  ) do
    in_kata do |id|
      assert_equal 'on', kata_option_get(id, 'colour')
    end
  end

  versions_01_test 'Ks3569', %w(
  | kata_option_get('colour') defaults to 'on' on pre-existing v0/v1 kata
  ) do
    kids = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    assert_equal 'on', kata_option_get(kids[version], 'colour')
  end

  version_test 2, 'Ks3561', %w(
  | kata_option_set('colour', on|off) sets the colour option
  | kata_option_get('colour') gets the colour option
  ) do
    in_kata do |id|
      kata_option_set(id, 'colour', 'on')
      assert_equal 'on', kata_option_get(id, 'colour')
      kata_option_set(id, 'colour', 'off')
      assert_equal 'off', kata_option_get(id, 'colour')
    end
  end

  version_test 2, 'Ks3562', %w(
  | kata_option_set('colour', not-on-not-off) raises
  ) do
    in_kata do |id|
      assert_raises { kata_option_set(id, 'colour', 'blue') }
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Ks3660', %w(
  | kata_option_get('predict') defaults to 'off'
  ) do
    in_kata do |id|
      assert_equal 'off', kata_option_get(id, 'predict')
    end
  end

  versions_01_test 'Ks3669', %w(
  | kata_option_get('predict') defaults to 'off' on pre-existing v0/v1 kata
  ) do
    kids = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    assert_equal 'off', kata_option_get(kids[version], 'predict')
  end

  version_test 2, 'Ks3661', %w(
  | kata_option_set('predict', on|off) sets the predict option
  | kata_option_get('predict') gets the predict option
  ) do
    in_kata do |id|
      kata_option_set(id, 'predict', 'on')
      assert_equal 'on', kata_option_get(id, 'predict')
      kata_option_set(id, 'predict', 'off')
      assert_equal 'off', kata_option_get(id, 'predict')
    end
  end

  version_test 2, 'Ks3662', %w(
  | kata_option_set('predict', not-on-not-off) raises
  ) do
    in_kata do |id|
      assert_raises { kata_option_set(id, 'predict', 'maybe') }
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Ks3760', %w(
  | kata_option_get('revert') defaults to 'off'
  ) do
    in_kata do |id|
      assert_equal 'off', kata_option_get(id, 'revert_red')
      assert_equal 'off', kata_option_get(id, 'revert_amber')
      assert_equal 'off', kata_option_get(id, 'revert_green')
    end
  end

  versions_01_test 'Ks3769', %w(
  | kata_option_get('revert') defaults to 'off' on pre-existing v0/v1 kata
  ) do
    kids = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    assert_equal 'off', kata_option_get(kids[version], 'revert_red')
    assert_equal 'off', kata_option_get(kids[version], 'revert_amber')
    assert_equal 'off', kata_option_get(kids[version], 'revert_green')
  end

  version_test 2, 'Ks3761', %w(
  | kata_option_set('revert', on|off) sets the revert option
  | kata_option_get('revert') gets the revert option
  ) do
    in_kata do |id|
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
  end

  version_test 2, 'Ks3762', %w(
  | kata_option_set('revert', not-on-not-off) raises
  ) do
    in_kata do |id|
      assert_raises { kata_option_set(id, 'revert_red'  , 'maybe') }
      assert_raises { kata_option_set(id, 'revert_amber', 'maybe') }
      assert_raises { kata_option_set(id, 'revert_green', 'maybe') }
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  version_test 2, 'Ks3860', %w(
  | kata_option_get(unknown key) raises
  ) do
    in_kata do |id|
      assert_raises { kata_option_get(id, 'salmon') }
      assert_raises { kata_option_get(id, 'revert_blue') }
    end
  end

  versions_01_test 'Ks3869', %w(
  | kata_option_get(unknown key) raises on pre-existing v0/v1 kata
  ) do
    kids = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    assert_raises { kata_option_get(kids[version], 'salmon') }
    assert_raises { kata_option_get(kids[version], 'revert_blue') }
  end

  version_test 2, 'Ks3861', %w(
  | kata_option_set(unknown key) raises
  ) do
    in_kata do |id|
      assert_raises { kata_option_set(id, 'salmon', 'atlantic') }
      assert_raises { kata_option_set(id, 'revert_blue', 'atlantic') }
    end
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_01_test 'Ks3863', %w(
  | kata_option_set raises NoLongerImplementedError
  | on v0/v1 katas
  ) do
    kids = { 0 => 'k5ZTk0', 1 => 'rUqcey' }
    assert_raises(NoLongerImplementedError) do
      kata_option_set(kids[version], 'theme', 'dark')
    end
  end

  version_test 0, 'Ks3864', %w(
  | kata_option_get('theme') returns stored value on pre-existing v0 kata
  | where theme was previously set to 'dark'
  ) do
    id = 'qNLm3j'
    dir = "/katas/#{id[0..1]}/#{id[2..3]}/#{id[4..5]}"
    disk.run(disk.dir_make_command(dir))
    disk.run_all([
      disk.file_create_command("#{dir}/manifest.json", '{"id":"qNLm3j"}'),
      disk.file_create_command("#{dir}/theme", "\ndark"),
    ])
    assert_equal 'dark', kata_option_get(id, 'theme')
  end
end
