module React
  class NativeElement
    # As of React 0.14, elements are now just plain object literals, so we can't inherit anymore
    # We can just set each of the properties on our object though
    # See var ReactElement = function (type, key, ref, self, source, owner, props) in the React source
    def initialize(native)
      %x{
        self.$$typeof = #{native}.$$typeof;
        self.type = #{native}.type;
        self.key = #{native}.key;
        self.ref = #{native}.ref;
        self.props = #{native}.props;
        self._owner = #{native}._owner;
        self._store = #{native}._store;
        self._self = #{native}._self;
        self._source = #{native}._source;
      }
    end

    def element_type
      self.JS[:type]
    end

    def on(event_name)
      name = event_name.to_s.camelize

      prop_key = "on#{name}"

      if React::Event::BUILT_IN_EVENTS.include?(prop_key)
        callback =  %x{
          function(event){
            #{yield React::Event.new(`event`)}
          }
        }
      else
        callback = %x{
          function(){
            #{yield *Array(`arguments`)}
          }
        }
      end

      new_prop = `{}`
      `new_prop[prop_key] = #{callback}`

      cloned = `React.cloneElement(#{self}, #{new_prop})`
      React::NativeElement.new cloned
    end
  end
end
