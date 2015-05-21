require 'json'
require 'webrick'

class Flash
  def initialize(req)
    @pend_flashes = {}

    @cookie = nil
    req.cookies.each do |el|
      @cookie = el if el.name == "_rails_lite_app_flash"
    end
    @cookie = WEBrick::Cookie.new("_rails_lite_app_flash", {}) if @show.nil?
    @show_flashes = @cookie.value
  end

  def [](key)
    @show[key]
  end

  def []=(key, val)
    @pend[key] = val
  end

  def keys
    @show.keys
  end

  def now
    @show_flashes = @pend_flashes
    @pend_flashes = nil
  end

  def store_session(res)
    @cookie.value = @pend_flashes.to_json
    res.cookies << @cookie
  end
end


# Solutions
# require 'json'
# require 'webrick'
#
# module Phase8
#   class HashWithIndifferentAccess < Hash
#     def [](key)
#       super(key.to_s)
#     end
#
#     def []=(key, val)
#       super(key.to_s, val)
#     end
#   end
#
#   class Flash
#     def initialize(req)
#       cookie = req.cookies.find { |c| c.name == '_rails_lite_app_flash' }
#
#       @flash_now = HashWithIndifferentAccess.new
#       @data = HashWithIndifferentAccess.new
#
#       if cookie
#         JSON.parse(cookie.value).each do |k, v|
#           @flash_now[k] = v
#         end
#       end
#     end
#
#     def now
#       @flash_now
#     end
#
#     def [](key)
#       now[key] || @data[key]
#     end
#
#     def []=(key, val)
#       now[key] = val
#       @data[key] = val
#     end
#
#     def store_flash(res)
#       cook = WEBrick::Cookie.new(
#         "_rails_lite_app_flash",
#         @data.to_json
#       )
#       cook.path = "/"
#       res.cookies << cook
#     end
#   end
# end


#Solutions in Controller Base

# require_relative '../phase6/controller_base'
# require_relative './flash'
#
# module Phase8
#   class ControllerBase < Phase6::ControllerBase
#     def redirect_to(url)
#       super(url)
#       flash.store_flash(@res)
#
#       nil
#     end
#
#     def render_content(content, type)
#       super(content, type)
#       flash.store_flash(@res)
#
#       nil
#     end
#
#     def flash
#       @flash ||= Flash.new(@req)
#     end
#   end
# end
