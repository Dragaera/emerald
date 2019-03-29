# coding: utf-8

module Emerald
  module Web
    class API < Grape::API
      logger Emerald.logger(program: 'api', module_: 'latex2png')
      use GrapeLogging::Middleware::RequestLogger, { logger: Emerald.logger(program: 'api', module_: 'requests') }

      helpers do
        def logger
          API.logger
        end
      end

      format :json

      resource :latex2png do

        desc "Renders a latex equation as PNG"
        params do
          requires :latex, type: String, desc: 'Latex body'
        end

        get :index do
          'hi'
        end
      end
    end
  end
end
