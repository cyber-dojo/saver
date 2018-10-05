require_relative 'id_splitter'

class ExternalIdValidator

  def initialize(externals)
    @externals = externals
  end

  def valid?(id)
    # eg '0215AFADCB'
    if id.upcase.include?('L')
      false
    else
      completions(id) == []
    end
  end

  def completions(id)
    args = [grouper.path, outer(id), inner(id)[0..3]]
    disk[File.join(*args)].completions
  end

  private

  include IdSplitter

  def grouper
    @externals.grouper
  end

  def disk
    @externals.disk
  end

end
