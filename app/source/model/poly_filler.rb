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

end
