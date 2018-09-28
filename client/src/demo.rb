require_relative 'grouper_service'
require_relative 'starter_service'

class Demo

  def call(_env)
    inner_call
  rescue => error
    [ 200, { 'Content-Type' => 'text/html' }, [ error.message ] ]
  end

  def inner_call
    html = [
      create,
      manifest
    ].join
    [ 200, { 'Content-Type' => 'text/html' }, [ html ] ]
  end

  private

  def create
    pre {
      @id = grouper.create(starter.manifest, starter.files)
    }
  end

  def manifest
    pre {
      grouper.manifest(@id)
    }
  end

  # - - - - - - - - - - - - - - - - -

  def name_of(caller)
    # eg caller[0] == "demo.rb:50:in `increments'"
    /`(?<name>[^']*)/ =~ caller[0] && name
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

  def pre(&block)
    result,duration = *timed { block.call }
    [
      "<pre>/#{name_of(caller)}(#{duration}s)</pre>",
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


