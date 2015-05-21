require_relative 'require'

class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    session
    flash
    @params = Params.new(req, route_params)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end

  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  def redirect_to(url)
    raise if already_built_response?
    @res.status = 302
    @res['Location'] = url
    @already_built_response = true
    @session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore

    string = File.read("./views/#{controller_name}/#{template_name}.html.erb")
      #"./" for project root dir

    template = ERB.new(string)
    capture = template.result(binding) #evaluate and bind

    render_content(capture, "text/html")
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise if already_built_response?
    @res.content_type = content_type
    @res.body = content
    @already_built_response = true
    @session.store_session(@res)
  end

  def already_built_response?
    @already_built_response
  end

end
