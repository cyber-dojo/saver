# frozen_string_literal: true
require_relative '../http_json_hash/service'
require_relative '../http_json_hash/service_error'

module External

  class Saver

    def initialize(http)
      service = 'saver'
      port = ENV['CYBER_DOJO_SAVER_PORT'].to_i
      @http = HttpJsonHash::service(self.class.name, http, service, port)
    end

    def ready?
      @http.get(__method__, {})
    end

    # - - - - - - - - - - - - - - - - - - -

    def dir_make_command(dirname)
      [ 'dir_make', dirname ]
    end

    def dir_exists_command(dirname)
      [ 'dir_exists?', dirname ]
    end

    def file_create_command(filename, content)
      [ 'file_create', filename, content ]
    end

    def file_append_command(filename, content)
      [ 'file_append', filename, content ]
    end

    def file_read_command(filename)
      [ 'file_read', filename ]
    end

    # - - - - - - - - - - - - - - - - - - -

    def assert(command)
      @http.post(__method__, { command:command })
    end

    def assert_all(commands)
      @http.post(__method__, { commands:commands })
    end

    # - - - - - - - - - - - - - - - - - - -

    def run(command)
      @http.post(__method__, { command:command })
    end

    def run_all(commands)
      @http.post(__method__, { commands:commands })
    end

    def run_until_true(commands)
      @http.post(__method__, { commands:commands })
    end

    def run_until_false(commands)
      @http.post(__method__, { commands:commands })
    end

  end

end
