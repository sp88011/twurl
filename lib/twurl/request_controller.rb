module Twurl
  class RequestController < AbstractCommandController
    NO_URI_MESSAGE = "No URI specified"
    def dispatch
      if client.needs_to_authorize?
        raise Exception, "You need to authorize first."
      end
      options.path ||= OAuthClient.rcfile.alias_from_options(options)
      perform_request
    end
    def perform_request
      client.perform_request_from_options(options) { |response|
        begin 
          response.read_body { |chunk|
             CLI.print chunk 
          }
        rescue Timeout::Error => ex
          CLI.puts "Ignoring timeout"
        end
      }
    rescue URI::InvalidURIError
      CLI.puts NO_URI_MESSAGE
    rescue Timeout::Error
      CLI.puts "Ignoring timeout"
    rescue Exception => e
      CLI.puts "Skipping exception "+e.inspect
    end
  end
end
