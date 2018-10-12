module ApplicationHelper
  def brahin_frontend_version
    if Rails.env.development?
      brahin_frontend_version_from_file
    else
      $brahin_frontend_version ||= ENV['BRAHIN_FRONTEND_VERSION'] || ENV['BRAHIN_VERSION'] || brahin_frontend_version_from_file
    end
  end

  def brahin_frontend_version_from_file
    [
      Rails.root.join('tmp', 'FRONTEND_VERSION').to_s,
      Rails.root.join('FRONTEND_VERSION').to_s,
    ].each do |version_fn|
      next if !File.exist?(version_fn)
      return File.read(version_fn).strip
    end
  end
end
