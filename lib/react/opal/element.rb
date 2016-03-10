require 'native'

module React
  # Need to make the React Element class/prototype inherit from this class
  class Element
    def new(native)
      raise "use React.create_element instead"
    end

    def element_type
      `self.type`
    end

    def key
      Native(`self.key`)
    end

    def props
      Hash.new(`self.props`)
    end

    def ref
      Native(`self.ref`)
    end

    def children
      nodes = `self.props.children`

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

    def to_n
      self
    end
  end
end
