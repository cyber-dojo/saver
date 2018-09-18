require_relative 'grouper_service'
require_relative 'starter_service'

class Demo

  def call(_env)
    inner_call
  rescue => error
    [ 200, { 'Content-Type' => 'text/html' }, [ error.message ] ]
  end

  def inner_call
    @html = ''
    create
    manifest
    [ 200, { 'Content-Type' => 'text/html' }, [ @html ] ]
  end

  private

  def create
    manifest = make_manifest
    manifest['created'] = [2016,12,2, 6,13,23]
    result,duration = *timed { @id = grouper.create(manifest) }
    @html += pre(__method__, result, duration)
  end

  def manifest
    result,duration = *timed { grouper.manifest(@id) }
    @html += pre(__method__, result, duration)
  end

  # - - - - - - - - - - - - - - - - -

  def make_manifest
    starter.language_manifest('C (gcc), assert', 'Fizz_Buzz')
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

  def pre(name, result, duration)
    border = 'border: 1px solid black;'
    padding = 'padding: 10px;'
    margin = 'margin-left: 30px; margin-right: 30px;'
    background = "background: white;"
    whitespace = "white-space: pre-wrap;"

    html = "<pre>/#{name}(#{duration}s)</pre>"
    html += "<pre style='#{whitespace}#{margin}#{border}#{padding}#{background}'>" +
            "#{JSON.pretty_unparse(result)}" +
            '</pre>'
    html
  end

  # - - - - - - - - - - - - - - - - -

  def grouper
    GrouperService.new
  end

  def starter
    StarterService.new
  end

end


