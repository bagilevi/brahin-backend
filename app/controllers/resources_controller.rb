class ResourcesController < ApplicationController
  include AccessLevel
  skip_before_action :verify_authenticity_token
  force_ssl if ENV['FORCE_SSL']
  before_action :enforce_authorization_for_creating, only: :create
  before_action :enforce_authorization_for_admin, only: [:share, :sharing, :update_sharing]

  def show
    if params[:edit]
      enforce_authorization_for_writing
      return if performed?
    end

    @resource = Resource.find_by_path(path_for_resource)

    if @resource
      enforce_authorization_for_reading
      return if performed?
      @load_frontend = authorized_to?(WRITE)
    else
      enforce_authorization_for_creating
      return if performed?
      @resource = Resource.find_or_initialize_by_path(path_for_resource)
      @load_frontend = true
    end

    if @resource.blank?
      render_error 'Not found', status: 404
      return
    end

    # TODO: model permissions & create presenter
    @resource_attributes = @resource.attributes.merge(
      permissions: {
        admin: authorized_to?(ADMIN),
        write: authorized_to?(WRITE),
      }
    )

    respond_to do |format|
      format.html
      format.json do
        render json: @resource_attributes
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
    @resource = Resource.find_by_path(path_for_resource)

    if @resource
      render_error 'Already exists', status: 409
      return
    end

    @resource = Resource.create(resource_params)
    @resource.save!
    authorize_created_resource

    respond_to do |format|
      format.html
      format.json do
        render json: @resource.attributes
      end
    end
  end

  def patch
    @resource = Resource.find_by_path(path_for_resource)

    if @resource
      enforce_authorization_for_writing
      return if performed?

      @resource.patch(resource_params)
      @resource.save!
    else
      enforce_authorization_for_creating
      return if performed?

      @resource = Resource.create(resource_params)
      @resource.save!
      authorize_created_resource
    end

    respond_to do |format|
      format.json do
        render json: { ok: true }
      end
    end
  end

  def share
    authorization = PathAuthorization.create!(
      path: path_for_authorization,
      token: params[:public].present? ? nil : TokenGenerator.generate_token(40),
      level: AccessLevel.level_from_string(params[:level]),
    )

    respond_to do |format|
      format.json do
        render json: { ok: true, access_token: authorization.token }
      end
    end
  end

  def sharing
    records =
      PathAuthorization.where(path: path_for_authorization)
        .order('level DESC')
        .to_a
    if records.empty?
      records = [
        PathAuthorization.create!(
          path: path_for_authorization,
          level: READ,
          token: TokenGenerator.generate_token
        )
      ]
    end

    data = records.map { |r| r.attributes.slice('path', 'token', 'level') }

    respond_to do |format|
      format.html
      format.json do
        render json: data
      end
    end
  end

  def update_sharing
    PathAuthorization.update_all_for_path(
      path_for_authorization,
      params.permit!.to_h[:entries] || []
    )
  end

  private

  def resource_params
    {
      title: params[:title],
      body: params[:body],
      path: path_for_resource
    }
  end

  def clean_path
    (params[:path] || '').sub(/^\//, '').sub(/.json$/, '')
  end

  def path_for_resource
    @path_for_resource ||= clean_path.presence || 'home'
  end

  def path_for_authorization
    "/#{clean_path}"
  end

  def enforce_authorization_for_writing
    return if authorized_to?(WRITE)
    render_error 'You are not authorized to edit this page.', status: 403
  end

  def enforce_authorization_for_reading
    return if authorized_to?(READ)
    render_error 'You are not authorized to see this page.', status: 403
  end

  def enforce_authorization_for_creating
    return if authorized_to?(CREATE)
    render_error 'You are not authorized to create this page.', status: 403
  end

  def enforce_authorization_for_admin
    return if authorized_to?(ADMIN)
    render_error 'You are not authorized to do this.', status: 403
  end

  def authorized_to?(action_level)
    @authorization ||= PathAuthorization.get(path_for_authorization, access_token)
    @authorization.can?(action_level).tap { |r|
      puts "authorized_to?(#{path_for_authorization}, #{action_level}, #{access_token}) => #{r.inspect}"
    }
  end

  def access_token
    @access_token ||=
      if (token = params[:access_token]).present?
        # Remember access token in a cookie
        cookies[:access_token] = {
          value: token,
          expires: 1.year,
          path: PathAuthorization.find_highest_path(path_for_authorization, token) || '/'
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

  def authorize_created_resource
    return unless authorized_to?(CREATE)

    PathAuthorization.create!(
      path: path_for_authorization,
      token: access_token,
      level: AccessLevel::ADMIN,
    )
  end

  def render_error(message, status: 500)
    puts "RENDER ERROR: #{message}"
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
