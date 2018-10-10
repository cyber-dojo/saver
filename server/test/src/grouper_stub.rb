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
  define_stubs :group_exists?, :group_create, :group_manifest
  define_stubs :group_join, :group_joined

end
