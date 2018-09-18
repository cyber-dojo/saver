
class StorerStub

  def sha
    "hello from #{self.class.name}.#{__method__}"
  end

  # - - - - - - - - - - - - - - - -

  def create(_)
    "hello from #{self.class.name}.#{__method__}"
  end

  def manifest(_)
    "hello from #{self.class.name}.#{__method__}"
  end

  # - - - - - - - - - - - - - - - -

  def id?(_)
    "hello from #{self.class.name}.#{__method__}"
  end

  def id_completed(_)
    "hello from #{self.class.name}.#{__method__}"
  end

  def id_completions(_)
    "hello from #{self.class.name}.#{__method__}"
  end

  # - - - - - - - - - - - - - - - -

  def ran_tests(_,_,_,_,_,_)
    "hello from #{self.class.name}.#{__method__}"
  end

  def increments(_)
    "hello from #{self.class.name}.#{__method__}"
  end

  # - - - - - - - - - - - - - - - -

  def visible_files(_)
    "hello from #{self.class.name}.#{__method__}"
  end

  def tag_visible_files(_,_)
    "hello from #{self.class.name}.#{__method__}"
  end

  def tags_visible_files(_,_,_)
    "hello from #{self.class.name}.#{__method__}"
  end

  #def tag_fork(_,_,_,_)
  #  "hello from #{self.class.name}.#{__method__}"
  #end

end
