require_relative '../request_error'

# An index into a kata's events, as a request names one. An index out
# of range is a request error, naming the index and how many events
# there are.
module EventIndex

  private

  # index as a position from the start of all_events: a -ve index
  # counts back from the end.
  def positive_index(index, all_events)
    if index < 0
      all_events.size + index
    else
      index
    end
  end

  # Raises a request error unless pos_index, from index, is a position
  # in all_events.
  def fail_unless_in_range(index, pos_index, all_events)
    unless pos_index >= 0
      fail RequestError, "Invalid -ve index #{index} (=> #{pos_index}) [#{plural(all_events.size, :event)}]"
    end
    fail_unless_before_end(pos_index, all_events)
  end

  # Raises a request error unless index, a position, is before the end
  # of all_events.
  def fail_unless_before_end(index, all_events)
    unless index < all_events.size
      fail RequestError, "Invalid +ve index #{index} [#{plural(all_events.size, :event)}]"
    end
  end

  # The event index of kata id that index names: index itself, or, for
  # a -ve index, the index of the event that many back from the last.
  def resolved_index(id, index)
    return index unless index < 0
    all_events = events(id)
    pos_index = positive_index(index, all_events)
    fail_unless_in_range(index, pos_index, all_events)
    all_events[pos_index]['index']
  end

  # The results of commands, which read the event at index of kata id,
  # after a run of them failed: a request error when index is past its
  # last event, which only then reads its events; otherwise the
  # commands run again, asserted, so a read that still fails raises.
  def reread_event(id, index, commands)
    fail_unless_before_end(index, events(id))
    disk.assert_all(commands)
  end

  # n of word, eg "1 event", "2 events".
  def plural(n, word)
    if n == 1
      "#{n} #{word}"
    else
      "#{n} #{word}s"
    end
  end

end
