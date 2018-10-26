class BlobsController < ApplicationController
  skip_before_action :verify_authenticity_token
  force_ssl if ENV['FORCE_SSL']

  def create
    uploaded_io = params[:upload]

    contents = uploaded_io.read
    path = Storage.storage.put_blob(contents, uploaded_io.original_filename)

    render json: { url: path }
  end

  def show
    content = Storage.storage.get_blob([params[:name], params[:format]].join('.'))
    send_data content, disposition: :inline, type: params[:format]
  end

  private

  HMAC_DIGEST = OpenSSL::Digest.new('sha1')

  def request_body
    @request_body ||= (
      request.body.rewind
      request.body.read
    )
  end
end
