require_relative 'test_base'

class CoverageEnvVarTest < TestBase

  test 'A4AB7D',
  'APP_DIR (for coverage metrics file) is set in server image downloaded from registry in workflow' do
    # If you update APP_DIR's value in the Dockerfile, you will also need to
    # update the target root-dirs in docker-compose.yml
    assert_equal ENV['APP_DIR'], '/saver'
  end
end
