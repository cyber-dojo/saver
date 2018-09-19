require_relative '../../src/grouper'

class GrouperStub

  def self.define_stubs(*names)
    names.each do |name|
      if Grouper.new(nil).respond_to?(name)
        define_method name do |*_args|
          "hello from #{self.class.name}.#{name}"
        end
      end
    end
  end

  define_stubs :sha
  define_stubs :create, :manifest
  define_stubs :id?, :id_completed, :id_completions
  define_stubs :join, :joined

end
