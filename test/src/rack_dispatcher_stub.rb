require_relative '../../src/grouper'
require_relative '../../src/singler'

class RackDispatcherStub

  def self.define_stubs(target_class, *names)
    target = target_class.new(nil)
    names.each do |name|
      if target.respond_to?(name)
        define_method name do |*_args|
          "hello from #{self.class.name}.#{name}"
        end
      end
    end
  end

  def self.define_grouper_stubs(*names)
    define_stubs(Grouper, *names)
  end

  def self.define_singler_stubs(*names)
    define_stubs(Singler, *names)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def sha
    "hello from #{self.class.name}.sha"
  end

  define_grouper_stubs :group_exists?,
                       :group_create,
                       :group_manifest,
                       :group_join,
                       :group_joined

  define_singler_stubs :kata_exists?,
                       :kata_create,
                       :kata_manifest,
                       :kata_ran_tests,
                       :kata_events,
                       :kata_event
end
