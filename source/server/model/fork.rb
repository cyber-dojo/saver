
module Fork

  def fork(forker, id, index)
    m = manifest(id)
    m['visible_files'] = event(id, index)['files']
    # Kata we are forking from may have been in a group
    # but leave no trace of that in the manifest.
    m.delete('group_id')
    m.delete('group_index')
    forker.new(@externals).create(m)
  end

end
