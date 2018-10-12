
class Image

  def initialize(disk)
    @disk = disk
  end

  def sha
    @disk['/app'].read('sha.txt').strip
  end

end