require_relative 'test_base'

class JoinScriptTest < TestBase

  def self.hex_prefix
    '69252'
  end

  def hex_setup
    @real_id_generator = externals.id_generator
    @stub_id_generator = IdGeneratorStub.new
    externals.id_generator = @stub_id_generator
  end

  def hex_teardown
    externals.id_generator = @real_id_generator
  end

  attr_reader :stub_id_generator

  # - - - - - - - - - - - - - - - - - - - - - - - - - -

=begin
  test '0E9',
  'returns another random number in range 0..63' do
    stub_create(id = '588AA6D4FB')

    born = []
    64.times do
      born << join(id)
    end
    assert_equal (0..63).to_a.sort, born.sort
    # this passes but is very slow....
  end
=end

  private

  def join(id)
    command = "flock /tmp/#{id} /app/src/join.rb #{pathed(id)}"
    logging = false
    stdout,stderr,status = shell.exec(command, logging)
    assert_equal '', stderr
    assert_equal 0, status
    stdout.to_i
  end

  def stub_create(stub_id)
    stub_id_generator.stub(stub_id)
    id = create(create_manifest)
    assert_equal stub_id, id
    id
  end

  def shell
    externals.shell
  end

  def pathed(id)
    "#{externals.grouper.path}/#{outer(id)}/#{inner(id)}"
  end

  def outer(id)
    id[0..1]  # 2-chars long. eg 'e5'
  end

  def inner(id)
    id[2..-1] # 8-chars long. eg '6aM327PE'
  end

end
