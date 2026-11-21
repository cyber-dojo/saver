module PolyFiller

  def polyfill_manifest(json, event0)
    json['visible_files'] = event0['files']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def polyfill_manifest_defaults(manifest)
    polyfill_defaults(manifest, manifest_defaults)
    polyfill_defaults(manifest, default_options)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def polyfill_event(event, events, index)
    event_summary = events[index]
    # event - read from /..ID../INDEX/event.json
    # events_summary - read from /..ID../events.json
    # Polyfill the former from the latter.
    polyfill_index_time(event, event_summary, index)
    polyfill_status(event)
    polyfill_created(event, index)
    polyfill_light(event, event_summary)
    polyfill_copied(event, event_summary, 'revert')
    polyfill_copied(event, event_summary, 'checkout')
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def polyfill_events(events)
    events.map.with_index(0) do |event,index|
      event['index'] = index
      if event.has_key?('colour')
        event['predicted'] ||= 'none'
      end
      event
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def polyfill_major_minor_events(events)
    major = 0
    minor = 0
    events[0]['major_index'] = major
    events[0]['minor_index'] = minor
    events[1..].each do |event|
      if is_light?(event)
        major += 1
        minor = 0
      else 
        minor += 1
      end
      event['major_index'] = major
      event['minor_index'] = minor      
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  FILE_EVENTS = %w( file_create file_delete file_rename file_edit )

  def is_light?(event)
    !FILE_EVENTS.include?(event['colour'])
  end

  private

  # The default of each manifest setting other than the options, new
  # on each call so no manifest shares another's arrays.
  def manifest_defaults
    {
      'version' => 0,
      'exercise' => '',
      'highlight_filenames' => [],
      'tab_size' => 4,
      'max_seconds' => 10,
      'progress_regexs' => []
    }
  end

  # Gives manifest each of defaults' values it lacks or has as nil or
  # false.
  def polyfill_defaults(manifest, defaults)
    defaults.each do |key,value|
      manifest[key] ||= value
    end
  end

  # Gives event its index, and the time event_summary has.
  def polyfill_index_time(event, event_summary, index)
    event['index'] = index
    event['time'] = event_summary['time']
  end

  # Makes event's status, when it has one, a string.
  def polyfill_status(event)
    if event.has_key?('status')
      event['status'] = event['status'].to_s
    end
  end

  # Names event at index 0 the created event.
  def polyfill_created(event, index)
    if index === 0
      event['event'] = 'created'
    end
  end

  # Gives event the colour, duration and prediction (none when
  # absent) of event_summary, when it is a light.
  def polyfill_light(event, event_summary)
    if event_summary.has_key?('colour')
      event['colour'] = event_summary['colour']
      event['duration'] = event_summary['duration']
      event['predicted'] = event_summary['predicted']
      event['predicted'] ||= 'none'
    end
  end

  # Gives event event_summary's value at key, when it has one.
  def polyfill_copied(event, event_summary, key)
    if event_summary.has_key?(key)
      event[key] = event_summary[key]
    end
  end

end
