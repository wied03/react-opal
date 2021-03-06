module React
  module Component
    module API
      def self.included(base)
        base.include(::React::PropsChildren)
      end

      def state
        Hash.new(`#{self}.state`)
      end

      def force_update!
        `#{self}.forceUpdate()`
      end

      def set_state(state, &block)
        %x{
        #{self}.setState(#{state.shallow_to_n}, function(){
            #{block.call if block}
          });
        }
      end

      def dom_node
        raise "`dom_node` is deprecated in favor of `React.find_dom_node`"
      end
    end
  end
end
