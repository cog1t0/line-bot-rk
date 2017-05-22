require 'line/bot'
class WebhookController < ApplicationController
  protect_from_forgery with: :null_session

  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  OUTBOUND_PROXY = ENV['LINE_OUTBOUND_PROXY']
  CHANNEL_ACCESS_TOKEN = ENV['CHANNEL_ACCESS_TOKEN']

  def callback
    logger.debug '======================== callback start ============================'
    unless is_validate_signature
      render :nothing => true, status: 470
    end

    event = params[:events][0]
    event_type = event["type"]
    replyToken = event["replyToken"]
    logger.debug "======================== event :#{event} ============================"
    logger.debug "======================== event_type :#{event_type} ============================"
    logger.debug "======================== replyToken :#{replyToken} ============================"

    case event_type
    when "message"
      input_text = event["message"]["text"]
      case input_text
      when "アンケート"
        puts "************************************************"
        puts reply_confirm_message
        reply = reply_confirm_message
        puts "************************************************"
      else
        reply = input_text
      end
    when "beacon"
      logger.debug "==================== beacon type : #{event["beacon"]["type"]}"
      case event["beacon"]["type"]
      when "enter"
        reply = "Beacon いらっしゃいませ！！"
      when "leave"
        reply = reply_confirm_message
      end
    when "postback"

    end

    client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    res = client.reply(replyToken, reply)
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts client
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    puts client2.try(inspect)
    puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

    #res = client.reply_message(replyToken, reply)
    puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end
    logger.debug '======================== callback end ============================'
    render :nothing => true, status: :ok
  end

  private
  def client2
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = CHANNEL_SECRET
      config.channel_token  = CHANNEL_ACCESS_TOKEN
    }
  end

  def is_validate_signature
    logger.debug '======================== is_validate_signature start ============================'
    #logger.info({request: request.inspect})
    # LINEからアクセス可能か確認
    # 認証に成功すればtrueを返す
    signature = request.headers["X-LINE-Signature"]
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
    signature_answer = Base64.strict_encode64(hash)
    signature == signature_answer
    logger.debug '======================== is_validate_signature end ============================'
  end

  def reply_confirm_message
    {
      type: "template",
      altText: "this is a confirm template",
      template: {
        type: "confirm",
        text: "本日は商品をご購入頂けましたか？",
        actions: [
          {
            type: "postback",
            label: "はい",
            data: "buy"
          },
          {
            type: "postback",
            label: "いいえ",
            data: "not_buy"
          }
        ]
      }
    }
  end
=begin
  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
      return
    end
    events = client.parse_events_from(body)
    events.each do |event|
      puts "=================================="
      puts event.inspect
      puts "=================================="

      case event
      when Line::Bot::Event::Postback
        puts "postback==>#{event['postback']['data']}"
          message =
            case event['postback']['data']
            when *%w(buy not_buy)
              [stamp_message, reply_button_message]
            when *%w(good niether bad)
              url = "https://www.jins.com/jp/common/img/ec/sunglasses2017SS.jpg"
              text = "ご回答ありがとうございます！！\n\nただいまサングラスのサマーセール中です。\n夏の紫外線対策に是非ご覧ください！！"
              [text_message(text), image_message(url), reply_carousel_message]
            end
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::Message
        puts "##################################"
        puts "message : #{event.message['text']}"
        case event.type
        when Line::Bott::Event::MessageType::Text
          message =
            case event.message['text']
            when 'アンケート' then
              reply_confirm_message
            else
              reply_text = Talk.new.smalltalk event.message['text']
              text_message reply_text
            end
          client.reply_message(event['replyToken'], message)
        end
      end
    end
    head :OK
  end

  private
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
  def text_message text
    {
      type: 'text',
      text: text
    }
  end
=end
end
