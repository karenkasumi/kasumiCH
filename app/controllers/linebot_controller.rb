class LinebotController < ApplicationController
    require 'line/bot'  # gem 'line-bot-api'
    require 'cgi'
  
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
            message=CGI.escapeHTML(event.message['text'])
            if message.match(/^view:/) then
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
                if message.match(/^red:/) then
                    message.sub!(/red:/,"")
                    colmessage=""
                    colmessage << "<font color=\"red\">" << message << "</font>"
                    message=colmessage
                elsif message.match(/^green:/) then
                    message.sub!(/green:/,"")
                    colmessage=""
                    colmessage << "<font color=\"green\">" << message << "</font>"
                    message=colmessage
                elsif message.match(/^col:(.+):/) then
                    color=message.match(/^col:(.+):/)[1]
                    message.sub!(/^col:(.+):/,"")
                    colmessage=""
                    colmessage << "<font color=\"" << color << "\">" << message << "</font>"
                    message=colmessage
                end

                if message.match(/http/) then
                    URI.extract(message).uniq.each do |url|
                      sub_text = ""
                      sub_text << "<a href=" << url << " target=\"_blank\">" << url << "</a>"
                
                      message.gsub!(url, sub_text)
                    end
                end
                Main.new(content: message,lineid:event['source']['userId'].to_s).save
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
      @posts = Main.all.order(created_at: "ASC")
    end
  end