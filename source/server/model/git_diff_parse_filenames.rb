module GitDiffParseFilenames
  def parse_old_new_filenames(header)
    old_filename, new_filename = old_new_filenames(header[0])
    new_filename = nil if header[1].start_with?('deleted file mode')
    old_filename = nil if header[1].start_with?('new file mode')
    old_filename = nil if header[2]&.start_with?('copy from')
    [old_filename, new_filename]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def old_new_filenames(first_line)
    old_new_filename_match(:uf, :uf, first_line) ||
      old_new_filename_match(:uf, :qf, first_line) ||
      old_new_filename_match(:qf, :qf, first_line) ||
      old_new_filename_match(:qf, :uf, first_line)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  FILENAME_REGEXS = {
    qf: '("(\\"|[^"])+")', # quoted-filename,   eg "b/emb ed\"ed.h"
    uf: '([^ ]*)' # unquoted-filename, eg a/plain
  }.freeze

  def old_new_filename_match(quote1, quote2, first_line)
    md = /^diff --git #{FILENAME_REGEXS[quote1]} #{FILENAME_REGEXS[quote2]}$/.match(first_line)
    return nil if md.nil?

    old_index = 1
    new_index = if quote1 == :uf
                  2
                else
                  3
                end
    [cleaned(md[old_index]), cleaned(md[new_index])]
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  def cleaned(filename)
    filename = unquoted(filename) if quoted?(filename)
    unescaped(filename)
  end

  def quoted?(filename)
    filename[0].chr == '"'
  end

  def unquoted(filename)
    filename[1..-2]
  end

  def unescaped(str)
    # Avoiding eval.
    # http://stackoverflow.com/questions/8639642/best-way-to-escape-and-unescape-strings-in-ruby
    unescapes = {
      '\\\\' => "\x5c",
      '"' => "\x22",
      "'" => "\x27"
    }
    str.gsub(/\\(?:([#{unescapes.keys.join}]))/) do
      ::Regexp.last_match(1) == '\\' ? '\\' : unescapes[::Regexp.last_match(1)]
    end
  end
end
