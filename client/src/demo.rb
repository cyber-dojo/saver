require_relative 'grouper_service'
require_relative 'starter_service'

class Demo

  def call(_env)
    inner_call
  rescue => error
    [ 400, { 'Content-Type' => 'text/html' }, [ error.message ] ]
  end

  private

  def inner_call
    html = [
      pre('create') {
        @id = grouper.create(starter.manifest, starter.files)
      },
      pre('manifest') {
        grouper.manifest(@id)
      },
      pre('join') {
        grouper.join(@id, (0..63).to_a.shuffle)
      },
      pre('joined') {
        grouper.joined(@id)
      }
    ].join
    [ 200, { 'Content-Type' => 'text/html' }, [ html ] ]
  end

  # - - - - - - - - - - - - - - - - -

  def timed
    started = Time.now
    result = yield
    finished = Time.now
    duration = '%.4f' % (finished - started)
    return [result,duration]
  end

  # - - - - - - - - - - - - - - - - -

  def pre(name, &block)
    result,duration = *timed { block.call }
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
    'background: white;'
  end

  def whitespace
    'white-space: pre-wrap;'
  end

  # - - - - - - - - - - - - - - - - -

  def grouper
    GrouperService.new
  end

  def starter
    StarterService.new
  end

end


