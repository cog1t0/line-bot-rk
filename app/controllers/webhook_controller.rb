require 'line/bot'
class WebhookController < ApplicationController
  protect_from_forgery with: :null_session

  CHANNEL_SECRET = ENV['LINE_CHANNEL_SECRET']
  OUTBOUND_PROXY = ENV['LINE_OUTBOUND_PROXY']
  CHANNEL_ACCESS_TOKEN = ENV['CHANNEL_ACCESS_TOKEN']
  APP_URL = 'https://line-bot-rk.herokuapp.com'

  def callback
    logger.debug '======================== callback start ============================'
    unless is_validate_signature
      render :nothing => true, status: 470
    end

    event = params[:events][0]
    event_type = event["type"]
    replyToken = event["replyToken"]
    line_user_id = event["source"]["userId"]
    user = User.find_by(line_user_id: line_user_id)
    logger.debug "======================== event :#{event} ============================"
    logger.debug "======================== event_type :#{event_type} ============================"
    logger.debug "======================== replyToken :#{replyToken} ============================"

    case event_type
    when "message"
      input_text = event["message"]["text"]
      case input_text
      when "アンケート"
        puts "************************************************"
        message = reply_confirm_message
        puts "************************************************"
      when "ユーザー登録"
        text = "ユーザー登録はこちらから行ってください。 #{APP_URL}/users/new?line_user_id=#{line_user_id}"
        message = text_message(text)
      when "出勤"
        if user.time_cards.present?
          if user.time_cards.last.work_date == Date.today
            logger.debug "********************* 本日は既に出勤済み ***************************"
            #本日すでに出勤済みには何もしない
          else
            logger.debug "********************* 出勤 ***************************"
            #出社
            record_arrival(user)
            message = text_message("おはようございます。今日も頑張りましょう！")
          end
        else
          logger.debug "********************* はじめての出勤 ***************************"
          #はじめての勤怠登録
          record_arrival(user)
          message = text_message("おはようございます。今日も頑張りましょう！")
        end
      when "退勤"
        t = user.time_cards.last
        if t.work_date == Date.today
          logger.debug "********************* 退勤 ***************************"
          #その日うちに帰る場合は、無条件でleave_timeを更新する
          t.leave_time = DateTime.now
          t.save
        else
          logger.debug "********************* 徹夜からの退勤 ***************************"
          #日付をまたいだ場合
          #TODO 仕様を詰める
        end
        message = text_message("お疲れさまでした。明日も頑張りましょう！出勤：#{t.arrival_time} 退勤：#{t.leave_time}")
      else
        message = text_message(input_text)
      end
    when "beacon"
      logger.debug "==================== beacon type : #{event["beacon"]["type"]}"
      case event["beacon"]["type"]
      when "enter"
        puts "************************************************"
        puts "beacon enter"
        puts "************************************************"
        if user.time_cards.present?
          puts "********************* 二回目以降の出勤 ***************************"
          if user.time_cards.last.work_date == Date.today
            puts "********************* 本日は既に出勤済み ***************************"
            #本日すでに出勤済みには何もしない
          else
            puts "********************* 出勤 ***************************"
            #出社
            record_arrival(user)
            message = text_message("おはようございます。今日も頑張りましょう！")
          end
        else
          puts "********************* はじめての出勤 ***************************"
          #はじめての勤怠登録
          record_arrival(user)
          message = text_message("おはようございます。今日も頑張りましょう！")
        end
      when "leave"
        puts "************************************************"
        puts "beacon leave"
        puts "************************************************"
        t = user.time_cards.last
        if t.work_date == Date.today
          puts "********************* 退勤 ***************************"
          #その日うちに帰る場合は、無条件でleave_timeを更新する
          t.leave_time = DateTime.now
          t.save
        else
          puts "********************* 徹夜からの退勤 ***************************"
          #日付をまたいだ場合
          #TODO 仕様を詰める
        end
        message = text_message("お疲れさまでした。明日も頑張りましょう！出勤：#{t.arrival_time} 退勤：#{t.leave_time}")
      end
    when "postback"

    end

    client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    res = client.reply(replyToken, message)
    puts "client : #{client}"

    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end

    logger.debug '======================== callback end ============================'
    render :nothing => true, status: :ok
  end

  private

  def record_arrival(user)
    t = user.time_cards.new
    t.work_date = Date.now
    t.arrival_time = DateTime.now
    t.save
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

  def text_message text
    {
      type: 'text',
      text: text
    }
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
