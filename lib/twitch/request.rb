module Twitch
  module Request
    def buildQueryString(options)
      query = "?"
      options.each do |key, value|
        query += "#{key}=#{value.to_s.gsub(" ", "+")}&"
      end
      query = query[0...-1]
    end

    def get(url)
      @adapter.get(url)
    end

    def post(url, data)
      @adapter.post(url, :body => data)
    end

    def put(url, data={})
      @adapter.put(url, :body => data, :headers => {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json',
          'Api-Version' => '2.2'
      })
    end
    
    def delete(url)
      @adapter.delete(url)
    end
  end
end
