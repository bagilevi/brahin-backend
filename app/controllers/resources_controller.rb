class ResourcesController < ApplicationController
  def show
    @resource = Resource.find_or_initialize_by_path(params[:path])
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
