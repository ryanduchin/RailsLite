require_relative '../phase2/controller_base'
require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'active_support/inflector'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    def render(template_name)
      controller_name = self.class.to_s.underscore
        #benefit of having this in a module!! :)

      string = File.read("./views/#{controller_name}/#{template_name}.html.erb")
        #"./" for project root dir

      template = ERB.new(string)
      capture = template.result(binding) #evaluate and bind

      render_content(capture, "text/html")


    end
  end
end
