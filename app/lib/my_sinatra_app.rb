require 'net/http'
require 'uri'

class MySinatraApp < Sinatra::Base
  get %r{/(memonite-.*\.(js|css))} do |name, ext|
    base_url = ENV['PLUGIN_BASE_URL'] || 'https://memonite.com/modules/'
    url = "#{base_url}#{name}"
    content = get_content_from_url(url)
    render_content(content, name, ext) || render_not_found
  end

  private

  def render_content(content, name, ext)
    headers 'Content-Type' => mime_format_from(ext),
            'Cache-Control' => 'no-cache'
    content
  end

  def get_content_from_url(url)
    Net::HTTP.get(URI.parse(url))
  end

  def mime_format_from(ext)
    case ext
    when 'js' then 'application/javascript'
    when 'css' then 'text/css'
    else 'text/plain'
    end
  end

  def render_not_found
    headers 'Content-Type' => 'text/plain'
    status 404
    'module not found'
  end
end
