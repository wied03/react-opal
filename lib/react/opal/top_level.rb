require 'native'
require 'active_support'

module React
  HTML_TAGS = %w(a abbr address area article aside audio b base bdi bdo big blockquote body br
                button canvas caption cite code col colgroup data datalist dd del details dfn
                dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5
                h6 head header hr html i iframe img input ins kbd keygen label legend li link
                main map mark menu menuitem meta meter nav noscript object ol optgroup option
                output p param picture pre progress q rp rt ruby s samp script section select
                small source span strong style sub summary sup table tbody td textarea tfoot th
                thead time title tr track u ul var video wbr)

  def self.create_element(type, properties = {})
    params = []

    # Component Spec or Normal DOM
    native = `(typeof type === 'function')` || HTML_TAGS.include?(type)
    params << if native
                type
              elsif type.kind_of?(Class)
                raise "Provided class should define `render` method" if !(type.method_defined? :render)
                React::ComponentFactory.native_component_class(type)
              else
                raise "#{type} not implemented"
              end

    # Passed in properties
    props = camel_case_hash_keys(properties) do |key, value|
      if key == "class_name" && value.is_a?(Hash)
        value.inject([]) { |ary, (k, v)| v ? ary.push(k) : ary }.join(" ")
      elsif key == 'value_link'
        process_value_link value
      else
        value
      end
    end

    params << props.shallow_to_n

    # Children Nodes
    if block_given?
      [yield].flatten.each do |ele|
        params << ele
      end
    end

    element = `React.createElement.apply(null, #{params})`
    element.class.include(React::Component::API) if native
    element
  end

  def self.lower_camelize(str)
    camelized = str.camelize
    camelized[0].downcase + camelized[1..-1]
  end

  def self.camel_case_hash_keys(input)
    as_array = input.map do |key, value|
      new_value = block_given? ? yield(key, value) : value
      [lower_camelize(key), new_value]
    end
    Hash[as_array]
  end

  def self.process_value_link(arguments)
    arguments = arguments.call if arguments.is_a? Proc
    camel_case_hash_keys(arguments).to_n
  end

  def self.render(element, container)
    component = Native(`ReactDOM.render(#{element}, container, function(){#{yield if block_given?}})`)
    component.class.include(React::Component::API)
    component
  end

  def self.is_valid_element(element)
    `React.isValidElement(#{element})`
  end

  def self.render_to_string(element)
    `ReactDOMServer.renderToString(#{element})`
  end

  def self.render_to_static_markup(element)
    `ReactDOMServer.renderToStaticMarkup(#{element})`
  end

  def self.unmount_component_at_node(node)
    `ReactDOM.unmountComponentAtNode(node)`
  end

  def self.expose_native_class(*args)
    args.each do |klass|
      `window[#{klass.to_s}] = #{React::ComponentFactory.native_component_class(klass)}`
    end
  end

  def self.find_dom_node(component)
    `ReactDOM.findDOMNode(#{component})`
  end
end
