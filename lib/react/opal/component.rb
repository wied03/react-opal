require 'active_support/core_ext/class/attribute'
require 'react/opal/callbacks'
require 'react/opal/ext/hash'
require 'react/opal/component/api'

module React
  module Component
    def self.included(base)
      base.include(API)
      base.include(React::Callbacks)
      base.class_eval do
        class_attribute :init_state, :validator, :context_types, :child_context_types, :child_context_get
        define_callback :before_mount
        define_callback :after_mount
        define_callback :before_receive_props
        define_callback :before_update
        define_callback :after_update
        define_callback :before_unmount
      end
      base.extend(ClassMethods)
    end

    def params
      Hash.new(`#{self}.props`).inject({}) do |memo, (k, v)|
        memo[k.underscore] = v
        memo
      end
    end

    def refs
      Hash.new(`#{self}.refs`)
    end

    def context
      Hash.new(`#{self}.context`)
    end

    def emit(event_name, *args)
      self.params["on_#{event_name.to_s}"].call(*args)
    end

    def component_will_mount
      self.run_callback(:before_mount)
    end

    def component_did_mount
      self.run_callback(:after_mount)
    end

    def component_will_receive_props(next_props)
      self.run_callback(:before_receive_props, Hash.new(next_props))
    end

    def should_component_update?(next_props, next_state)
      self.respond_to?(:needs_update?) ? self.needs_update?(Hash.new(next_props), Hash.new(next_state)) : true
    end

    def component_will_update(next_props, next_state)
      self.run_callback(:before_update, Hash.new(next_props), Hash.new(next_state))
    end

    def component_did_update(prev_props, prev_state)
      self.run_callback(:after_update, Hash.new(prev_props), Hash.new(prev_state))
    end

    def component_will_unmount
      self.run_callback(:before_unmount)
    end

    def p(*args, &block)
      if block || args.count == 0 || (args.count == 1 && args.first.is_a?(Hash))
        _p_tag(*args, &block)
      else
        Kernel.p(*args)
      end
    end

    def method_missing(name, *args, &block)
      unless (React::HTML_TAGS.include?(name) || name == 'present' || name == '_p_tag')
        return super
      end

      if name == "present"
        name = args.shift
      end

      if name == "_p_tag"
        name = "p"
      end

      @buffer = [] unless @buffer
      if block
        current = @buffer
        @buffer = []
        result = block.call
        element = React.create_element(name, *args) { @buffer.count == 0 ? result : @buffer }
        @buffer = current
      else
        element = React.create_element(name, *args)
      end

      @buffer << element
      element
    end

    def to_n
      self
    end

    module ClassMethods
      def prop_types
        if self.validator
          {
              _componentValidator: %x{
              function(props, propName, componentName) {
                var errors = #{validator.validate(Hash.new(`props`))};
                var error = new Error(#{"In component `" + self.name + "`\n" + `errors`.join("\n")});
                return #{`errors`.count > 0 ? `error` : `undefined`};
              }
            }
          }
        else
          {}
        end
      end

      def initial_state
        self.init_state || {}
      end

      def default_props
        self.validator ? self.validator.default_props : {}
      end

      def params(&block)
        if self.validator
          self.validator.evaluate_more_rules(&block)
        else
          self.validator = React::Validator.build(&block)
        end
      end

      def define_state_prop(prop, &block)
        define_state prop
        update_value = lambda do |new_value|
          new_value = instance_exec(new_value, &block) if block
          self.send("#{prop}=", new_value)
        end
        before_mount do
          # need to execute in context of each object
          instance_exec params[prop], &update_value
        end
        before_receive_props do |new_props|
          # need to execute in context of each object
          instance_exec new_props[prop], &update_value
        end
      end

      def get_prop_type(klass)
        if klass == Proc
          `React.PropTypes.func`
        elsif klass.is_a?(Proc)
          `React.PropTypes.object`
        elsif klass == Boolean
          `React.PropTypes.bool`
        elsif klass.ancestors.include?(Numeric)
          `React.PropTypes.number`
        elsif klass == String
          `React.PropTypes.string`
        elsif klass == Array
          `React.PropTypes.array`
        else
          `React.PropTypes.object`
        end
      end

      def consume_context(item, klass)
        self.context_types ||= {}
        self.context_types[item] = get_prop_type(klass)
      end

      def provide_context(item, klass, &block)
        self.child_context_types ||= {}
        self.child_context_types[item] = get_prop_type(klass)
        self.child_context_get ||= {}
        self.child_context_get[item] = block
        unless method_defined?(:get_child_context)
          define_method(:get_child_context) do
            Hash[self.child_context_get.map do |item, blk|
                   [item, instance_eval(&blk)]
                 end].to_n
          end
        end
      end

      def define_state(*states)
        raise "Block could be only given when define exactly one state" if block_given? && states.count > 1

        self.init_state = {} unless self.init_state

        if block_given?
          self.init_state[states[0]] = yield
        end
        states.each do |name|
          # getter
          define_method("#{name}") do
            self.state[name]
          end
          # setter
          define_method("#{name}=") do |new_state|
            hash = {}
            hash[name] = new_state
            self.set_state(hash)

            new_state
          end
        end
      end
    end
  end
end
