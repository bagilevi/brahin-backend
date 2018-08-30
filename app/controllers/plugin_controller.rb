  require 'net/http'
  require 'uri'

class PluginController < ApplicationController
  force_ssl if ENV['FORCE_SSL']

  def show
    name = params[:name]
    url  = params[:url]
    type = params[:type] || 'js'

    serve_from_file(name, type) ||
      serve_from_file(name.sub('-v0.2.1', '-v1'), type) ||
      serve_from_url(url, type) ||
      render_not_found
  end

  private

  def serve_from_file(name, type)
    return if name.blank?
    path = Rails.root.join('public', 'modules', "#{name}.#{type}").to_s
    if File.exist?(path)
      send_file(path, filename: "#{name}.#{type}", type: mime_type_from(type))
      true
    end
  end

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
    else raise "unhandled type: #{type.inspect}"
    end
  end

  def render_not_found
    render plain: "module not found\n", status: 404
  end
end
