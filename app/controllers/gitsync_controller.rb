class GitsyncController < ApplicationController
  skip_before_action :verify_authenticity_token
  force_ssl if ENV['FORCE_SSL']

  def pull
    if secret = ENV['GITHUB_WEBHOOK_SECRET']
      expected_signature = "sha1=#{OpenSSL::HMAC.hexdigest(HMAC_DIGEST, secret, request_body)}"
      actual_signature = request.headers['X-Hub-Signature']
      if actual_signature != expected_signature
        Rails.logger.warn("Invalid signature in GitHub hook - expected: #{expected_signature} - actual: #{actual_signature}")
        render plain: "ERR\nbad_signature\n", status: 403
        return
      end
    end
    GitSync.notify_pull
    render plain: "OK\n"
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
