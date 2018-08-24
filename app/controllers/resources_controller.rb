class ResourcesController < ApplicationController
  def show
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
end
