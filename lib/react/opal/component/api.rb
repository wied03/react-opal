module React
  module Component
    module API
      def state
        Hash.new(`#{self}.state`)
      end

      def props
        Hash.new(`#{self}.props`)
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

      def children
        nodes = `#{self}.props.children`

        if `React.Children.count(nodes)` == 0
          `[]`
        elsif `React.Children.count(nodes)` == 1
          if `(typeof nodes === 'string') || (typeof nodes === 'number')`
            [nodes]
          else
            `[React.Children.only(nodes)]`
          end
        else
          # Not sure the overhead of doing this..
          class << nodes
            include Enumerable

            def to_n
              self
            end

            def each(&block)
              if block_given?
                %x{
                                React.Children.forEach(#{self.to_n}, function(context){
                                  #{block.call(`context`)}
                                })
                              }
              else
                Enumerator.new(`React.Children.count(#{self.to_n})`) do |y|
                  %x{
                                  React.Children.forEach(#{self.to_n}, function(context){
                                    #{y << `context`}
                                  })
                                }
                end
              end
            end
          end

          nodes
        end
      end
    end
  end
end
