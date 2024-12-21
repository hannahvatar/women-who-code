class BotController < ApplicationController
  def ask
    user_question = params[:question]
    Rails.logger.info "User Question: #{user_question}"

    begin
      if user_question.present? && user_question.match?(/future|destiny|will|tomorrow|what's next/i)
        @answer = get_openai_response(user_question)
      elsif user_question.present?
        @answer = "Ask me something about your future!"
      else
        @answer = nil
      end

      Rails.logger.info "Final Answer: #{@answer}"

    rescue => e
      Rails.logger.error "Error in ask action: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @answer = "Sorry, there was an error processing your question."
    end
  end

  private

  def get_openai_response(question)
    begin
      # Log the API key presence (not the actual key)
      api_key = Rails.application.credentials.openai[:api_key]
      Rails.logger.info "API Key check - Key exists?: #{api_key.present?}"

      client = OpenAI::Client.new(access_token: api_key)
      Rails.logger.info "Client initialized successfully"

      request_params = {
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            {
              role: "system",
              content: "You are a mystical fortune teller with a sense of humor. Keep responses entertaining and under 2 sentences."
            },
            {
              role: "user",
              content: question
            }
          ],
          temperature: 0.8,
          max_tokens: 150
        }
      }
      Rails.logger.info "Sending request with parameters: #{request_params.inspect}"

      begin
        response = client.chat(**request_params)
        Rails.logger.info "API call successful, response received"
      rescue Faraday::TooManyRequestsError => e
        Rails.logger.error "Rate limit exceeded: #{e.message}"
        return "The fortune teller is taking a short break due to high demand. Please try again in a few minutes! 🔮✨"
      rescue => e
        Rails.logger.error "API call failed: #{e.class} - #{e.message}"
        raise
      end

      # Process response
      if response.nil?
        Rails.logger.error "Response was nil"
        return "The crystal ball is clouded. Try again!"
      end

      Rails.logger.info "Full response structure: #{response.inspect}"

      content = response.dig("choices", 0, "message", "content")
      Rails.logger.info "Extracted content: #{content.inspect}"

      return content || "The stars are misaligned. Ask again!"

    rescue OpenAI::Error => e
      Rails.logger.error "OpenAI API Error: #{e.class} - #{e.message}"
      handle_openai_error(e)
    rescue => e
      Rails.logger.error "ERROR CLASS: #{e.class}"
      Rails.logger.error "ERROR MESSAGE: #{e.message}"
      Rails.logger.error "BACKTRACE: #{e.backtrace.join("\n")}"
      "The fortune teller's crystal ball needs maintenance. Check back soon!"
    end
  end

  def handle_openai_error(error)
    case error
    when OpenAI::Error::InvalidRequestError
      "The crystal ball detected an invalid question. Try rephrasing!"
    when OpenAI::Error::AuthenticationError
      Rails.logger.error "Authentication failed with OpenAI"
      "The fortune teller's license has expired! Try again later."
    when OpenAI::Error::RateLimitError
      "Too many seekers of wisdom! Please try again in a moment."
    else
      "The mystic forces are temporarily unavailable. Try again soon!"
    end
  end
 end
