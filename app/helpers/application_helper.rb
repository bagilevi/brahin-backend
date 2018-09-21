module ApplicationHelper
  def memonite_version
    if Rails.env.development?
      memonite_version_from_file
    else
      $memonite_version ||= ENV['MEMONITE_VERSION'] || memonite_version_from_file
    end
  end

  def memonite_version_from_file
    [
      Rails.root.join('tmp', 'VERSION').to_s,
      Rails.root.join('VERSION').to_s,
    ].each do |version_fn|
      next if !File.exist?(version_fn)
      return File.read(version_fn).strip
    end
  end
end
