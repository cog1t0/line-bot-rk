require 'sinatra'   # gem 'sinatra'
require 'line/bot'  # gem 'line-bot-api'

class HTTPProxyClient
  def http(uri)
    proxy = URI(ENV['FIXIE_URL'])
    proxy_class = Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password)
    http = proxy_class.new(uri.host, uri.port)
    if uri.scheme == "https"
      http.use_ssl = true
    end
    http
  end

  def get(url, header = {})
    uri = URI(url)
    http(uri).get(uri.request_uri, header)
  end

  def post(url, payload, header = {})
    uri = URI(url)
    http(uri).post(uri.request_uri, payload, header)
  end
end

def client
  @client ||= Line::Bot::Client.new do |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["CHANNEL_ACCESS_TOKEN"]
    config.httpclient = HTTPProxyClient.new
  end
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)

  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: event.message['text']
        }
        p client.reply_message(event['replyToken'], message)
      end
    end
  }

  "OK"
end
