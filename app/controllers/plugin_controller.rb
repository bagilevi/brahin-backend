  require 'net/http'
  require 'uri'

class PluginController < ApplicationController
  force_ssl if ENV['FORCE_SSL']

  def show
    name = params[:name]
    type = params[:type]

    url = "#{ENV['PLUGIN_BASE_URL']}#{name}#{".#{type}" if type.present?}"

    serve_from_url(url, type) ||
      render_not_found
  end

  private

  def serve_from_url(url, type)
    return if url.blank?
    content = get_content_from_url(url)
    if content
      send_data(content, filename: File.basename(url), type: mime_type_from(type))
    end
  end

  def get_content_from_url(url)
    Net::HTTP.get(URI.parse(url))
  end

  def mime_type_from(type)
    case type
    when 'js' then 'application/javascript'
    when 'css' then 'text/css'
    else 'text/plain'
    end
  end

  def render_not_found
    render plain: "module not found\n", status: 404
  end
end
