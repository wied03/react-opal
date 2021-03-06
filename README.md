# React-opal

[![Build Status](http://img.shields.io/travis/wied03/react-opal/master.svg?style=flat)](http://travis-ci.org/wied03/react-opal)
[![Version](http://img.shields.io/gem/v/react-opal.svg?style=flat-square)](https://rubygems.org/gems/react-opal)

**React-opal is a a fork of the original [React.rb](https://github.com/zetachang/react.rb)  [Opal Ruby](http://opalrb.org) wrapper of [React.js library](http://facebook.github.io/react/)**.

## Why fork?
* Keep it simple, don't create an entire framework, just focus on React and Opal
* Test driven development is important

It lets you write reactive UI components, with Ruby's elegance and compiled to run in JavaScript. :heart:

## Installation

# TBD
```ruby
# Gemfile
gem "react-opal"
```

and in your Opal application,

```ruby
require "opal"
require "react-opal"

React.render(React.create_element('h1'){ "Hello World!" }, `document.body`)
```

**Note:** This library does not directly include a react source dependency but you need to ensure you have React 0.14.
We don't include the dependency in this GEM in order to allow you to use your preferred packaging (NPM, Bower, GEMs, etc.).
Thus the version number of the react-opal GEM simply reflects which version of React that react-opal has been tested with.

For integration with server (Sinatra, etc), see setup of [TodoMVC](examples/todos) or the [official docs](http://opalrb.org/docs/) of Opal.

## Usage

### A Simple Component

A ruby class which define method `render` is a valid component.

```ruby
class HelloMessage
  def render
    React.create_element("div") { "Hello World!" }
  end
end

puts React.render_to_static_markup(React.create_element(HelloMessage))

# => '<div>Hello World!</div>'
```

## Testing your components

You can use whatever opal friendly testing framework you want. Make sure that if you're using Phantom JS 1.98, you include the es5-shim before the React dependency

More to come about how we do this internally with opal-rspec.

### More complicated one

To hook into native ReactComponent life cycle, the native `this` will be passed to the class's initializer. And all corresponding life cycle methods (`componentDidMount`, etc) will be invoked on the instance using the snake-case method name.

```ruby
class HelloMessage
  def initialize(native)
    @native = Native(native)
  end

  def component_will_mount
    puts "will mount!"
  end

  def render
    React.create_element("div") { "Hello #{@native[:props][:name]}!" }
  end
end

puts React.render_to_static_markup(React.create_element(HelloMessage, name: 'John'))

# => will_mount!
# => '<div>Hello John!</div>'
```

### React::Component

Hey, we are using Ruby, simply include `React::Component` to save your typing and have some handy methods defined.

```ruby
class HelloMessage
  include React::Component
  MSG = {great: 'Cool!', bad: 'Cheer up!'}

  define_state(:foo) { "Default greeting" }

  before_mount do
    self.foo = "#{self.foo}: #{MSG[params[:mood]]}"
  end

  after_mount :log

  def log
    puts "mounted!"
  end

  def render
    div do
      span { self.foo + " #{params[:name]}!" }
    end
  end
end

class App
  include React::Component

  def render
    present HelloMessage, name: 'John', mood: 'great'
  end
end

puts React.render_to_static_markup(React.create_element(App))

# => '<div><span>Default greeting: Cool! John!</span></div>'

React.render(React.create_element(App), `document.body`)

# mounted!
```

* Callback of life cycle could be created through helpers `before_mount`, `after_mount`, etc
* `this.props` is accessed through method `self.params`
* Use helper method `define_state` to create setter & getter of `this.state` for you
* For the detailed mapping to the original API, see [this issue](https://github.com/zetachang/react.rb/issues/2) for reference. Complete reference will come soon.

### Element Building DSL

As a replacement of JSX, include `React::Component` and you can build `React.Element` hierarchy without all the `React.create_element` noises.

```ruby
def render
  div do
    h1 { "Title" }
    h2 { "subtitle"}
    div(class_name: 'fancy', id: 'foo') { span { "some text #{interpolation}"} }
    present FancyElement, fancy_props: '10'
  end
end
```

### Context

You can use the [React context](https://www.tildedave.com/2014/11/15/introduction-to-contexts-in-react-js.html) feature to pass values down a component hierarchy chain.

```ruby
class ParentComponent
  include React::Component
  
  # Simply supply the Ruby/Opal type that :foo will be and react-opal will map that to a React PropType automatically
  provide_context(:foo, Fixnum) { params[:foo_value] }
  
  def render
    present ChildComponent
  end
end

class ChildComponent
  include React::Component
  
  consume_context(:foo, Fixnum)
  
  def render
    # will render the :foo_value prop passed into ParentComponent
    div { "foo is #{self.context[:foo]}" } 
  end
end
```

### Props validation

How about props validation? Inspired by [Grape API](https://github.com/intridea/grape), props validation rule could be created easily through `params` class method as below,

```ruby
class App
  include React::Component

  params do
    requires :username, type: String
    requires :enum, values: ['foo', 'bar', 'awesome']
    requires :payload, type: Todo # yeah, a plain Ruby class
    optional :filters, type: Array[String]
    optional :flash_message, type: String, default: 'Welcome!' # no need to feed through `getDefaultProps`
  end
	
  # Will append to the params above
  params do
    requires :password, type: String
  end

  def render
    div
  end
end
```

### Mixins

Simply create a Ruby module to encapsulate the behavior. Example below is modified from the original [React.js Exmaple on Mixin](http://facebook.github.io/react/docs/reusable-components.html#mixins). [Opal Browser](https://github.com/opal/opal-browser) syntax are used here to make it cleaner.

```ruby
module SetInterval
  def self.included(base)
    base.class_eval do
      before_mount { @interval = [] }
      before_unmount do
        # abort associated timer of a component right before unmount
        @interval.each { |i| i.abort }
      end
    end
  end

  def set_interval(seconds, &block)
    @interval << $window.every(seconds, &block)
  end
end

class TickTock
  include React::Component
  include SetInterval

  define_state(:seconds) { 0 }

  before_mount do
    set_interval(1) { self.seconds = self.seconds + 1 }
    set_interval(1) { puts "Tick!" }
  end

  def render
    span do
      "React has been running for: #{self.seconds}"
    end
  end
end

React.render(React.create_element(TickTock), $document.body.to_n)

$window.after(5) do
  React.unmount_component_at_node($document.body.to_n)
end

# => Tick!
# => ... for 5 times then stop ticking after 5 seconds
```

## Example

* React Tutorial: see [examples/react-tutorial](examples/react-tutorial), the original CommentBox example.
* TodoMVC: see [examples/todos](examples/todos), your beloved TodoMVC <3.
* JSX Example: see [examples/basic-jsx](examples/basic-jsx).

## React Native

For [React Native](http://facebook.github.io/react-native/) support, please refer to [Opal Native](https://github.com/zetachang/opal-native).

## TODOS

* Documentation
* API wrapping coverage of the original js library (pretty close though)

## Developing

To run the test case of the project yourself.

1. `git clone` the project
2. `bundle install`
3. `bundle exec rackup`
4. Open `http://localhost:9292` to run the spec

## Contributions

This project is still in early stage, so discussion, bug report and PR are really welcome :wink:.

## Contact

TBD

## License

Originally Copyright (c) 2015 Yi-Cheng Chang (http://github.com/zetachang)
Portions copyright (c) 2016, BSW Technology Consulting LLC

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

In short, React.rb is available under the MIT license. See the LICENSE file for more info.
