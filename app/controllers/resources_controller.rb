class ResourcesController < ApplicationController
  include AccessLevel
  skip_before_action :verify_authenticity_token
  force_ssl if ENV['FORCE_SSL']

  rescue_from Errors::NotFoundError do |e|
    render_error e.message, status: 404
  end

  rescue_from Errors::UnauthorizedError do |e|
    render_error e.message, status: 403
  end

  rescue_from Errors::AlreadyExistsError do |e|
    render_error e.message, status: 409
  end

  def show
    result = ShowResource.(
      path: path,
      edit: params[:edit].present?,
      access_token: access_token,
    )

    @resource_attributes = result.resource_attributes
    @load_frontend = @resource_attributes[:permissions][:write]

    respond_to do |format|
      format.html
      format.json do
        render json: result.resource_attributes
      end
    end
  end

  # A static cachable page served to the service worker for any resource endpoint
  # with no actual resource but with the purpose of initialising the SPA.
  def spa_dummy
    @load_frontend = true
  end

  # A static page that triggers local-store mode.
  def local
    @load_frontend = true
  end

  def create
    result = CreateResource.(
      path: path,
      access_token: access_token,
      params: {
        title: params[:title],
        body: params[:body],
      }
    )

    respond_to do |format|
      format.html
      format.json do
        render json: @resource.attributes
      end
    end
  end

  def patch
    result = UpdateResource.(
      path: path,
      access_token: access_token,
      params: {
        title: params[:title],
        body: params[:body],
      }
    )

    respond_to do |format|
      format.json do
        render json: { ok: true }
      end
    end
  end

  def permissions
    data = GetPermissions.(
      path:         path,
      access_token: access_token
    )
    respond_to do |format|
      format.json do
        render json: data
      end
    end
  end

  def update_permissions
    grants = params.permit!.to_h[:grants] || []
    if grants.is_a?(Hash)
      grants = grants.map { |k, v| v }
    end

    UpdatePermissions.(
      path:         path,
      access_token: access_token,
      grants:       grants,
    )
    respond_to do |format|
      format.json do
        render json: { ok: true }
      end
    end
  end

  private

  def path
    ResourcePath[params[:path]]
  end

  def access_token
    @access_token ||=
      if (token = params[:access_token]).present?
        # Remember access token in a cookie
        cookies[:access_token] = {
          value: token,
          expires: 1.year,
          path: PermissionGrant.find_highest_path(path, token) || '/'
        }
        token
      elsif cookies[:access_token].present?
        cookies[:access_token]
      else
        # Create a random token for the user
        token = TokenGenerator.generate_token(40)
        cookies[:access_token] = {
          value: token,
          expires: 1.year,
          path: '/'
        }
        token
      end
  end

  def render_error(message, status: 500)
    respond_to do |format|
      format.html do
        render plain: message, status: status
      end
      format.json do
        render json: { error: message }, status: status
      end
    end
  end
end
