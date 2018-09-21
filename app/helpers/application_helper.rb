module ApplicationHelper
  def brahin_version
    if Rails.env.development?
      brahin_version_from_file
    else
      $brahin_version ||= ENV['BRAHIN_VERSION'] || brahin_version_from_file
    end
  end

  def brahin_version_from_file
    [
      Rails.root.join('tmp', 'VERSION').to_s,
      Rails.root.join('VERSION').to_s,
    ].each do |version_fn|
      next if !File.exist?(version_fn)
      return File.read(version_fn).strip
    end
  end
end
