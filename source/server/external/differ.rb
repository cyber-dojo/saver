require_relative 'http_json/service'
require_relative 'http'

module External

  class Differ

    def initialize
      hostname = ENV.fetch('CYBER_DOJO_DIFFER_HOSTNAME', 'differ')
      port = ENV['CYBER_DOJO_DIFFER_PORT'].to_i
      http = External::Http.new
      @http = HttpJson::service(self.class.name, http, hostname, port)
    end

    def diff_lines(was_files, now_files)
      @http.get(:diff_lines_files, { was_files: was_files, now_files: now_files })
    end

    def diff_summary(was_files, now_files)
      @http.get(:diff_summary_files, { was_files: was_files, now_files: now_files })
    end

  end

end
