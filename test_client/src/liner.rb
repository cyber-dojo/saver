# frozen_string_literal: true

module Liner # mix-in

  def lined_files(files)
    files.each {|_filename,file| lined_file(file) }
  end

  def unlined_files(files)
    files.each {|_filename,file| unlined_file(file) }
  end

  def lined_file(file)
    unless file.nil?
      content = file['content']
      if content == ''
        # [ '' ] is more visually obvious than []
        # Note: [''].join == [].join == ''
        file['content'] = [ '' ]
      else
        file['content'] = content.lines
      end
    end
  end

  def unlined_file(file)
    unless file.nil?
      file['content'] = file['content'].join
    end
  end

end
