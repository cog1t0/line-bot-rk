class WebhookController < ApplicationController
  protect_from_forgery :except => [:callback]

  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  OUTBOUND_PROXY = ENV['LINE_OUTBOUND_PROXY']
  CHANNEL_ACCESS_TOKEN = ENV['CHANNEL_ACCESS_TOKEN']

  def callback
    unless is_validate_signature
      render :nothing => true, status: 470
    end

    event = params[:events][0]
    event_type = event["type"]
    replyToken = event["replyToken"]

    case event_type
    when "message"
      input_text = event["message"]["text"]
      output_text = input_text
    end

    client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    res = client.reply(replyToken, output_text)

    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end
    render :nothing => true, status: :ok
  end

  private

  def is_validate_signature
    logger.info({is_validate_signature: 'start'})
    logger.info({request: request.inspect})
    # LINEからアクセス可能か確認
    # 認証に成功すればtrueを返す
    signature = request.headers["X-LINE-Signature"]
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
    signature_answer = Base64.strict_encode64(hash)
    signature == signature_answer
  end
end

