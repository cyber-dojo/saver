module PolyFiller

  def polyfill_manifest(json, event0)
    json['visible_files'] = event0['files']
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def polyfill_manifest_defaults(manifest)
    manifest['version'] ||= 0
    manifest['exercise'] ||= ''
    manifest['highlight_filenames'] ||= []
    manifest['tab_size'] ||= 4
    manifest['max_seconds'] ||= 10
    manifest['progress_regexs'] ||= []
    default_options.each do |key,value|
      manifest[key] ||= value
    end
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def polyfill_event(event, events, index)
    event_summary = events[index]
    # event - read from /..ID../INDEX/event.json
    # events_summary - read from /..ID../events.json
    # Polyfill the former from the latter.
    if event.has_key?('status')
      event['status'] = event['status'].to_s
    end
    if index === 0
      event['event'] = 'created'
    end
    if event_summary.has_key?('colour')
      event['colour'] = event_summary['colour']
      event['duration'] = event_summary['duration']
      event['predicted'] = event_summary['predicted']
      event['predicted'] ||= 'none'
    end
    if event_summary.has_key?('revert')
      event['revert'] = event_summary['revert']
    end
    if event_summary.has_key?('checkout')
      event['checkout'] = event_summary['checkout']
    end
    event['index'] = index
    event['time'] = event_summary['time']
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

  def polyfill_major_minor(events)
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

end
