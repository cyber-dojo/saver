
module Liner # mix-in

  def lined(files)
    Hash[files.map {|filename,content|
      [filename,content.lines]
    }]
  end

  def unlined(files)
    Hash[files.map {|filename,lines|
      [filename, lines.join]
    }]
  end

end
