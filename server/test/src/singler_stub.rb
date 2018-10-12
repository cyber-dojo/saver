require_relative '../../src/singler'

class SinglerStub

  def self.define_stubs(*names)
    names.each do |name|
      if Singler.new(nil).respond_to?(name)
        define_method name do |*_args|
          "hello from #{self.class.name}.#{name}"
        end
      end
    end
  end

  define_stubs :sha
  define_stubs :kata_exists?, :kata_create, :kata_manifest
  define_stubs :kata_ran_tests, :kata_tags, :kata_tag

end
