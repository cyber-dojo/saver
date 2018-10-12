require_relative '../../src/grouper'

class RackDispatcherStub

  def self.define_grouper_stubs(*names)
    names.each do |name|
      if Grouper.new(nil).respond_to?(name)
        define_method name do |*_args|
          "hello from #{self.class.name}.#{name}"
        end
      end
    end
  end

  def self.define_singler_stubs(*names)
    names.each do |name|
      if Singler.new(nil).respond_to?(name)
        define_method name do |*_args|
          "hello from #{self.class.name}.#{name}"
        end
      end
    end
  end

  def sha
    "hello from #{self.class.name}.sha"
  end

  define_grouper_stubs :group_exists?, :group_create, :group_manifest
  define_grouper_stubs :group_join, :group_joined

  define_singler_stubs :kata_exists?, :kata_create, :kata_manifest
  define_singler_stubs :kata_ran_tests, :kata_tags, :kata_tag

end
