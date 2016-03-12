def get_dom_node(react_element)
  rendered_element = `React.addons.TestUtils.renderIntoDocument(#{react_element})`
  React.find_dom_node rendered_element
end

def get_jq_node(react_element)
  dom_node = get_dom_node react_element
  dom_node ? Element.find(dom_node) : nil
end

def find_element_jq_node(react_element, element_type)
  jq_dom_node = get_jq_node react_element
  return nil unless jq_dom_node
  elements = jq_dom_node.find(element_type)
  elements.any? ? elements : nil
end

def change_value_in_element(element, value, element_type=:select)
  rendered = `React.addons.TestUtils.renderIntoDocument(#{element})`
  parent_node = React.find_dom_node rendered
  element = Element.find(parent_node).find(element_type)
  element_native = element.get()[0]
  `React.addons.TestUtils.Simulate.change(#{element_native}, {target: {value: #{value}}})`
end

RSpec::Matchers.define :contain_dom_element do |element_type|
  match do |react_element|
    @element = find_element_jq_node react_element, element_type
    next false unless @element
    # Don't make the test get the type exactly right
    @element.value.to_s == @expected_value.to_s
  end

  failure_message do |react_element|
    if @element
      "Found element, but value was '#{@element.value}' and we expected '#{@expected_value}'"
    else
      "Expected rendered element to contain a #{element_type}, but it did not, did contain this: #{Native(get_dom_node(react_element)).outerHTML}"
    end
  end

  chain :with_selected_value do |expected_value|
    @expected_value = expected_value
  end
end
