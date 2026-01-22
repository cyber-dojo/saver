require_relative 'test_base'

class KataOptionTest < TestBase

  def id58_setup
    @id = kata_create(custom_manifest)
  end

  attr_reader :id

  # - - - - - - - - - - - - - - - - -

  versions_test 'f27460', %w(
  | kata_option_get('theme') defaults to 'light' as that is better on projectors
  ) do
    assert_equal 'light', kata_option_get('theme')
  end

  versions_test 'f27461', %w(
  | kata_option_set('theme', dark|light) sets the theme option
  | kata_option_get('theme') gets the theme option
  ) do
    kata_option_set('theme', 'dark')
    assert_equal 'dark', kata_option_get('theme')
    kata_option_set('theme', 'light')
    assert_equal 'light', kata_option_get('theme')
  end

  versions_test 'f27462', %w(
  | kata_option_set('theme', not-dark-not-light) raises
  ) do
    capture_stdout_stderr {
      assert_raises { kata_option_set('theme', 'grey') }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'f27560', %w(
  | kata_option_get('colour') defaults to 'on'
  ) do
    assert_equal 'on', kata_option_get('colour')
  end

  versions_test 'f27561', %w(
  | kata_option_set('colour', on|off) sets the colour option
  | kata_option_get('colour') gets the colour option
  ) do
    kata_option_set('colour', 'on')
    assert_equal 'on', kata_option_get('colour')
    kata_option_set('colour', 'off')
    assert_equal 'off', kata_option_get('colour')
  end

  versions_test 'f27562', %w(
  | kata_option_set('colour', not-on-not-off) raises
  ) do
    capture_stdout_stderr {
      assert_raises { kata_option_set('colour', 'blue') }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'f27660', %w(
  | kata_option_get('predict') defaults to 'off'
  ) do
    assert_equal 'off', kata_option_get('predict')
  end

  versions_test 'f27661', %w(
  | kata_option_set('predict', on|off) sets the predict option
  | kata_option_get('predict') gets the predict option
  ) do
    kata_option_set('predict', 'on')
    assert_equal 'on', kata_option_get('predict')
    kata_option_set('predict', 'off')
    assert_equal 'off', kata_option_get('predict')
  end

  versions_test 'f27662', %w(
  | kata_option_set('predict', not-on-not-off) raises
  ) do
    capture_stdout_stderr {
      assert_raises { kata_option_set('predict', 'maybe') }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'f27760', %w(
  | kata_option_get('revert') defaults to 'off'
  ) do
    assert_equal 'off', kata_option_get('revert_red')
    assert_equal 'off', kata_option_get('revert_amber')
    assert_equal 'off', kata_option_get('revert_green')
  end

  versions_test 'f27761', %w(
  | kata_option_set('revert', on|off) sets the revert option
  | kata_option_get('revert') gets the revert option
  ) do
    kata_option_set('revert_red', 'on')
    assert_equal 'on', kata_option_get('revert_red')
    kata_option_set('revert_red', 'off')
    assert_equal 'off', kata_option_get('revert_red')

    kata_option_set('revert_amber', 'on')
    assert_equal 'on', kata_option_get('revert_amber')
    kata_option_set('revert_amber', 'off')
    assert_equal 'off', kata_option_get('revert_amber')

    kata_option_set('revert_green', 'on')
    assert_equal 'on', kata_option_get('revert_green')
    kata_option_set('revert_green', 'off')
    assert_equal 'off', kata_option_get('revert_green')
  end

  versions_test 'f27762', %w(
  | kata_option_set('revert', not-on-not-off) raises
  ) do
    capture_stdout_stderr {
      assert_raises { kata_option_set('revert_red', 'maybe') }
    }
    capture_stdout_stderr {
      assert_raises { kata_option_set('revert_amber', 'maybe') }
    }
    capture_stdout_stderr {
      assert_raises { kata_option_set('revert_green', 'maybe') }
    }
  end

  #- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  versions_test 'f27860', %w(
  | kata_option_get(unknown) raises
  ) do
    capture_stdout_stderr {
      assert_raises { kata_option_get('salmon') }
    }
    capture_stdout_stderr {
      assert_raises { kata_option_get('revert_blue') }
    }
  end

  versions_test 'f27861', %w(
  | kata_option_set(unknown) raises
  ) do
    capture_stdout_stderr {
      assert_raises { kata_option_set('salmon', 'atlantic') }
    }
    capture_stdout_stderr {
      assert_raises { kata_option_set('revert_blue', 'off') }
    }
  end

end
