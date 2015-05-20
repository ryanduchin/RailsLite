require 'webrick'
require_relative '../lib/phase4/controller_base'

# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html

class MyController < Phase4::ControllerBase
  def go
    session["count"] ||= 0
    #calls session method in controllerbase
      #calls session initialize which gets the cookie
    session["count"] += 1
      #changes the session cookie value
    render :counting_show
      #calls our render method which renders the template
      #end of render method calls render_content
      # * this calls our Phase4::ControllerBase version which additionally
      # =>calls store_session(@res) and adds the cookie value (to JSON) to cookies
  end
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  MyController.new(req, res).go
end

trap('INT') { server.shutdown }
server.start
