require_relative 'saver_service'
#require_relative 'starter'

class Demo

  def call(_env)
    inner_call
  rescue => error
    [ 400, { 'Content-Type' => 'text/html' }, [ error.message ] ]
  end

  private

  def inner_call
    html = [
      pre('group_create') {
        @gid = saver.group_create(starter.manifest)
      },
      pre('group_manifest') {
        saver.group_manifest(@gid)
      },
      pre('group_join') {
        saver.group_join(@gid, (0..63).to_a.shuffle)
      },
      pre('group_joined') {
        saver.group_joined(@gid)
      },
      pre('kata_create') {
        @kid = saver.kata_create(starter.manifest)
      },
      pre('kata_manifest') {
        saver.kata_manifest(@kid)
      },
      pre('kata_ran_tests') {
        saver.kata_ran_tests(@kid, 1, edited_files, now, duration, stdout, stderr, status, colour)
      },
      pre('kata_events') {
        saver.kata_events(@kid)
      },
      pre('kata_event') {
        saver.kata_event(@kid, 1)
      }
    ].join
    [ 200, { 'Content-Type' => 'text/html' }, [ html ] ]
  end

  # - - - - - - - - - - - - - - - - -

  def edited_files
    files = starter.manifest['visible_files']
    hiker_c = files['hiker.c']
    hiker_c['content'].sub!('6 * 9', '6 * 7')
    files
  end

  def now
    [2016,12,2, 6,14,37,456]
  end

  def duration
    1.8934
  end

  def stdout
    { 'content' => 'All tests passed' }
  end

  def stderr
    { 'content' => '' }
  end

  def status
    0
  end

  def colour
    'green'
  end

  # - - - - - - - - - - - - - - - - -

  def timed
    started = Time.now
    result = yield
    finished = Time.now
    duration = '%.4f' % (finished - started)
    [result,duration]
  end

  # - - - - - - - - - - - - - - - - -

  def pre(name, &block)
    result,duration = timed { block.call }
    [
      "<pre>/#{name}(#{duration}s)</pre>",
      "<pre style='#{style}'>",
        "#{JSON.pretty_unparse(result)}",
      '</pre>'
    ].join
  end

  def style
    [whitespace,margin,border,padding,background].join
  end

  def border
    'border: 1px solid black;'
  end

  def padding
    'padding: 10px;'
  end

  def margin
    'margin-left: 30px; margin-right: 30px;'
  end

  def background
    'background:LightGreen;'
  end

  def whitespace
    'white-space: pre-wrap;'
  end

  # - - - - - - - - - - - - - - - - -

  def saver
    SaverService.new
  end

  def starter
    Starter.new
  end

end
