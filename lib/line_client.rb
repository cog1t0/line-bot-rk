class LineClient
  # 参考 http://qiita.com/YoheiMiyamoto/items/f6851cdb40891edf0e57
  END_POINT = "https://api.line.me"

  def initialize(channel_access_token, proxy = nil)
    @channel_access_token = channel_access_token
    @proxy = proxy
  end

  def post(path, data)
    client = Faraday.new(:url => END_POINT) do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
      conn.proxy @proxy
    end

    res = client.post do |request|
      request.url path
      request.headers = {
        'Content-type' => 'application/json',
        'Authorization' => "Bearer #{@channel_access_token}"
      }
      request.body = data
    end
    res
  end

  def reply(replyToken, message)
    messages = [message]
    body = {
      "replyToken" => replyToken,
      "messages" => messages
    }
    post('/v2/bot/message/reply', body.to_json)
  end
end
