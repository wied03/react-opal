module ChildrenTesting
  def get_kids(element)
    nodes = `#{element}.props.children`

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

RSpec::Matchers.define :have_children do |matcher|
  include ChildrenTesting

  match do |element|
    matcher.matches? get_kids(element)
  end

  failure_message do
    matcher.failure_message
  end
end

RSpec::Matchers.define :have_children_types do |matcher|
  include ChildrenTesting

  match do |element|
    kids = get_kids(element)
    types = kids.map { |kid| kid.JS[:type] }
    matcher.matches? types
  end

  failure_message do
    matcher.failure_message
  end
end
