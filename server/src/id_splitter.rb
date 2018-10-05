
module IdSplitter # mix-in

  def outer(id)
    id[0..1]
  end

  def inner(id)
    id[2..-1]
  end

end
