module Phase6
  class Route
    # instantiates the appropriate controller with appropriate method

    attr_reader :pattern, :http_method, :controller_class, :action_name
    # pattern: The URL pattern it is meant to match
    # => (/users, /users/new, /users/(\d+), /users/(\d+)/edit, etc.
    # http_method: POST, PUT, GET, DELETE (symbols)
    # controller_class: which controller
    # action_name: method in controller (like index or show)

    def initialize(pattern, http_method, controller_class, action_name)
      #these come from the Router which comes from the request
      @pattern = pattern
      @http_method = http_method
      @controller_class = controller_class
      @action_name = action_name
      #?
    end

    # checks if pattern matches path and method matches request method
    def matches?(req)
      match_method = req.request_method.downcase.to_sym == @http_method
      # match_pattern = req.path.match(Regexp.new(@pattern))
      match_pattern = req.path =~ @pattern
      match_method && match_pattern
    end

    # use pattern to pull out route params (save for later?)
    # instantiate controller and call controller action
    def run(req, res)
      @route_params = {}

      # I need to build route_params from the URL params
      # @pattern is the regexp
      match_data = @pattern.match(req.path)
        # * @pattern is the regexp given in the router.draw block in
        #   p06_router_server.rb
        # * req.path is the url we are matching against
        #   match_data gives us the MatchData object
      match_data.names.each do |name|
        @route_params[name] = match_data[name]
      end

      controller_instance = @controller_class.new(req, res, @route_params)
      controller_instance.invoke_action(@action_name)
    end
  end

  class Router
    # has methods for 4 HTTP verbs, each one adds @routes << Route.new
    attr_reader :routes

    def initialize
      @routes = []
    end

    # simply adds a new route to the list of routes
    def add_route(pattern, method, controller_class, action_name)
      @routes << Route.new(pattern, method, controller_class, action_name)
    end

    def draw(&proc)
      self.instance_eval(&proc)
    end

    # created methods that add their new route to @routes
    [:get, :post, :put, :delete].each do |http_method|
      define_method(http_method) do |pattern, controller_class, action_name|
        add_route(pattern, http_method, controller_class, action_name)
      end
    end

    def match(req)
      @routes.find { |route| route.matches?(req) }
    end

    # either throw 404 or call run on a matched route
    def run(req, res)
      if match(req).nil?
        res.status = 404
      else
        match(req).run(req, res)
      end
    end
  end
end
