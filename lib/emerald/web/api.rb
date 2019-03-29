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

      resource do
        desc "Renders a latex equation as PNG"
        params do
          requires :latex, type: String, desc: 'Latex body'
        end
        get do
          latex = params[:latex]
          doc = LatexDocument.new(latex: latex)
          out = {}

          begin
            image = doc.to_image

            content_type 'application/png'
            env['api.format'] = :binary
            header 'Content-Disposition', "attachment; filename*=UTF-8''#{ URI.escape(image) }"
            body File.binread(image)
          rescue RuntimeError => e
            error!({ error: e.message }, 500)
          ensure
            doc.clear
          end
        end
      end
    end
  end
end
