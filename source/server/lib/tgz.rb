require_relative 'gnu_zip'
require_relative 'tarfile_writer'

module TGZ

  def self.of(files)
    writer = TarFile::Writer.new
    files.each do |filename, content|
      writer.write(filename, content)
    end
    Gnu.zip(writer.tar_file)
  end

end
