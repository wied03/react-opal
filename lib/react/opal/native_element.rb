module React
  class NativeElement
    include React::Component::API

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
  end
end
