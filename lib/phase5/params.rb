require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = route_params
      parse_www_encoded_form(req.query_string) if req.query_string
      parse_www_encoded_form(req.body) if req.body

      p "req.query_string is #{!req.query_string.nil?}"
      p "req.body is #{!req.body.nil?}"
    end

    def [](key)
      @params[key.to_sym] || @params[key.to_s]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      @params = {}

      URI::decode_www_form(www_encoded_form).each do |pair|
          # * URI.decode_www_form(user[address][street]=main&user[address][zip]=89436)
          # => [["user[address][street]", "main"], ["user[address][zip]", "89436"]]

        current = @params
          # * current points at params so we are changing that piece of
          #   of memory.
          # * On each iteration we are resetting the pointer to the array
          #   we just generated with current, but pointing to the whole thing

        keys = parse_key(pair.first)
          # * parse_key("user[address][street]")
          # => ["user", "address", "street"]
        val = pair.last
          # * "main" (plus the other pairs)

        keys.each_with_index do |key, idx|
          if idx == keys.length - 1 #last index
            current[key] = val
          else
            current[key] ||= {}
              #if it already exists, build on it!
            current = current[key]
          end
        end
        @params
      end
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end
  end
end
