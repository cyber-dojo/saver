
module Version

  def version
    name = ENV['CYBER_DOJO_TEST_NAME']
    if name.start_with?('<version=0>')
      0
    elsif name.start_with?('<version=1>')
      1
    elsif name.start_with?('<version=2>')
      2
    end
  end

end
