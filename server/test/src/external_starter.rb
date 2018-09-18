require_relative 'http_json_service'

class ExternalStarter

  def language_manifest(display_name, exercise_name)
    json = get([display_name, exercise_name], __method__)
    manifest = json['manifest']
    manifest['exercise'] = exercise_name
    manifest['visible_files']['instructions'] = json['exercise']
    manifest
  end

  private

  include HttpJsonService

  def hostname
    'starter'
  end

  def port
    4527
  end

end