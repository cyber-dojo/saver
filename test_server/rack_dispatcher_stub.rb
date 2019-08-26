require_relative '../src/group'
require_relative '../src/kata'

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

  def self.define_group_stubs(*names)
    define_stubs(Group, *names)
  end

  def self.define_kata_stubs(*names)
    define_stubs(Kata, *names)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def ready?
    "hello from #{self.class.name}.ready?"
  end

  def sha
    "hello from #{self.class.name}.sha"
  end

  define_group_stubs :group_exists?,
                     :group_create,
                     :group_manifest,
                     :group_join,
                     :group_joined,
                     :group_events

  define_kata_stubs :kata_exists?,
                    :kata_create,
                    :kata_manifest,
                    :kata_ran_tests,
                    :kata_events,
                    :kata_event
end
