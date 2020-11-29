class LinebotController < ApplicationController
    require 'line/bot'  # gem 'line-bot-api'
  
    # callbackアクションのCSRFトークン認証を無効
    protect_from_forgery :except => [:callback]
  
    def client
      @client ||= Line::Bot::Client.new { |config|
        config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
        config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
    end
  
    def callback
      body = request.body.read
  
      signature = request.env['HTTP_X_LINE_SIGNATURE']
      unless client.validate_signature(body, signature)
        head :bad_request
      end
  
      events = client.parse_events_from(body)
  
      events.each { |event|
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            message=html_escape(event.message['text'])
            if messege.match(/^view:/) then
                res=""
                n=Main.all.length
                for i in 0..9
                  res <<"["<< Main.all[n-10+i].id.to_s << ":" << Main.all[n-10+i].content << "]"
                end
                message = {
                    type: 'text',
                    text: res
                  }
                  client.reply_message(event['replyToken'], message)
            else
                if massege.match(/^red:/) then
                    message.delete!("red:")
                    colmessage=""
                    colmessage << "<front color="red">" << message << "</front>"
                    message=colmessage
                elsif message.match(/^green:/) then
                    message.delete!("green:")
                    colmessage=""
                    colmessage << "<front color="green">" << message << "</front>"
                    message=colmessage
                end
                Main.new(content: message).save
                message = {
                    type: 'text',
                    text: message
                  }
                  client.reply_message(event['replyToken'], message)        
            end  
          end
        end
      }
  
      head :ok
    end

    def index
      @posts = Main.all
    end
  end