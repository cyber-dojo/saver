# frozen_string_literal: true
require 'rubygems/package'  # Gem::Package::TarReader
require 'stringio'
require_relative 'utf8_clean'

module TarFile

  class Reader

    def initialize(tar_file)
      io = StringIO.new(tar_file, 'r+t')
      @reader = Gem::Package::TarReader.new(io)
    end

    def files
      @reader.each.with_object({}) do |entry,memo|
        filename = Utf8.clean(entry.full_name)
        content = Utf8.clean(entry.read || '') # avoid nil
        memo[filename] = content
      end
    end

  end

end
