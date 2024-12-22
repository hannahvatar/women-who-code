class BotController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:ask]  # Only if needed for testing

  def show
    Rails.logger.info "==== Bot Controller: Show Action Called ===="
  end

  def ask
    Rails.logger.info "==== Bot Controller: Ask Action Started ===="
    Rails.logger.info "Params received: #{params.inspect}"

    user_question = params[:question]
    Rails.logger.info "User question: #{user_question}"

    begin
      if user_question.present? && user_question.match?(/future|destiny|will|tomorrow|what's next/i)
        Rails.logger.info "Question is about the future, calling OpenAI..."
        @answer = get_openai_response(user_question)
        Rails.logger.info "OpenAI response received: #{@answer}"
      elsif user_question.present?
        @answer = "Ask me something about your future!"
        Rails.logger.info "Non-future related question"
      else
        @answer = nil
        Rails.logger.info "No question provided"
      end

      Rails.logger.info "Sending response: #{@answer}"

      # Handle both console testing and web requests
      if request.present? && request.format.json?
        render json: { answer: @answer }
      else
        @answer
      end

    rescue => e
      Rails.logger.error "==== ERROR in Bot Controller ===="
      Rails.logger.error "Error class: #{e.class}"
      Rails.logger.error "Error message: #{e.message}"

      error_response = "Sorry, there was an error processing your question."

      if request.present? && request.format.json?
        render json: { answer: error_response }, status: :internal_server_error
      else
        error_response
      end
    end
  end

  private

  def get_openai_response(question)
    Rails.logger.info "==== Starting OpenAI Request ===="
    begin
      # USE ENV instead of Rails.application.credentials
      api_key = ENV['OPENAI_API_KEY']
      Rails.logger.info "API Key present?: #{api_key.present?}"

      # Add explicit error if API key is missing
      unless api_key.present?
        Rails.logger.error "No OpenAI API key found in environment variables"
        return "The mystic portal is sealed. No API key detected!"
      end

      client = OpenAI::Client.new(access_token: api_key)
      Rails.logger.info "Client initialized"

      # Define request parameters
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

      Rails.logger.info "Making API request to OpenAI..."

      response = client.chat(**request_params)
      Rails.logger.info "Raw OpenAI response: #{response.inspect}"

      if response.nil?
        Rails.logger.error "Received nil response from OpenAI"
        return "The crystal ball is clouded. Try again!"
      end

      content = response.dig("choices", 0, "message", "content")
      Rails.logger.info "Extracted content: #{content.inspect}"

      if content.nil?
        Rails.logger.error "Could not extract content from response"
        return "The stars are misaligned. Ask again!"
      end

      return content

    rescue OpenAI::Error => e
      Rails.logger.error "OpenAI API Error: #{e.class} - #{e.message}"
      handle_openai_error(e)
    rescue => e
      Rails.logger.error "Unexpected error in OpenAI request: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      "The fortune teller's crystal ball needs maintenance. Check back soon!"
    end
  end

  def handle_openai_error(error)
    Rails.logger.error "==== Handling OpenAI Error ===="
    Rails.logger.error "Error type: #{error.class}"

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
