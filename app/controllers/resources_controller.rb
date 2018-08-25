class ResourcesController < ApplicationController
  force_ssl if ENV['FORCE_SSL']
  before_action :authenticate_for_reading, only: :show
  before_action :authenticate_for_writing, only: [:create, :patch]
  before_action :sanitize_path

  def show
    if params[:edit]
      authenticate_for_writing
    end

    @authorized_to_write = authorized_to_write?

    @resource = Resource.find_or_initialize_by_path(params[:path])

    respond_to do |format|
      format.html
      format.json do
        render json: @resource.attributes
      end
    end
  end

  def create
    @resource = Resource.find_by_path(params[:path])

    if (@resource)
      format.html do
        render text: 'Already exists'
      end
      format.json do
        render json: { error: 'Already exists' }, status: 409
      end
      return
    end

    @resource = Resource.create(
      path: params[:path],
      title: params[:title],
    )
    @resource.save!

    respond_to do |format|
      format.html
      format.json do
        render json: @resource.attributes
      end
    end
  end

  def patch
    respond_to do |format|
      format.json do
        Resource.patch_by_path(params)
        render json: { ok: true }
      end
    end
  end

  private

  def sanitize_path
    params[:path] = (params[:path] || '').sub(/.json$/, '').presence || 'home'
  end

  def authorized_to_write?
    authorized_to?('write')
  end

  def authorized_to_read?
    authorized_to?('read') || authorized_to?('write')
  end

  def authenticate_for_writing
    return if authorized_to_write?
    request_http_basic_authentication
  end

  def authenticate_for_reading
    return if authorized_to_read?
    request_http_basic_authentication
  end

  def authorized_to?(permission)
    # Everyone can do anything if no configuration set.
    return true if $auth_config.blank?

    return true if $auth_config.has_wildcard?(permission)

    authenticate_with_http_basic do |username, password|
      $auth_config.match?(permission, username, password)
    end
  end
end
