require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      @cookie = nil
      req.cookies.each do |el|
        @cookie = el if el.name == "_rails_lite_app"
      end

      if @cookie.nil?
        @cookie = WEBrick::Cookie.new("_rails_lite_app", {})
        @cookie_val = @cookie.value
      else
        @cookie_val = JSON.parse(@cookie.value)
      end
    end

    def [](key)
      @cookie_val[key]
    end

    def []=(key, val)
      @cookie_val[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      @cookie.value = @cookie_val.to_json
      res.cookies << @cookie
    end
  end
end
