module BookLab
  module GraphQL
    class IntegrationTest < ActiveSupport::TestCase
      attr_accessor :response

      def execute(query_string, context: nil)
        context ||= { current_user: @current_user }
        @response = BookLabSchema.execute(query_string, context: context)
        assert_not_nil @response
      end

      def response_data
        @response["data"]
      end

      def response_errors
        @response["errors"]
      end

      def sign_in(user)
        @current_user = user
      end

      def assert_error_with(message)
        found = false
        response_errors.each do |error|
          if error["message"] == message
            found = true
            break
          end
        end

        assert_equal true, found, <<~MSG
        expected: #{response_errors.inspect}
        include:  #{message}
        MSG
      end

      def assert_unauthorized
        assert_error_with("You are not authorized to access this page.")
      end
    end
  end
end
