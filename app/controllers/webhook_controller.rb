#require 'line/bot'
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
      output_text = input_text
    when "beacon"
      logger.debug "==================== beacon type : #{event["beacon"]["type"]}"
      case event["beacon"]["type"]
      when "enter"
        output_text = "Beacon いらっしゃいませ！！"
      when "leave"
        output_text = "Beacon いってらっしゃいませ！！"
      end
    when "postback"

    end

    client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    res = client.reply(replyToken, output_text)

    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end
    logger.debug '======================== callback end ============================'
    render :nothing => true, status: :ok
  end

  private

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
end
