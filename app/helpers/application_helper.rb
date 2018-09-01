module ApplicationHelper
  def memonite_version
    if Rails.env.development?
      memonite_version_from_file
    else
      $memonite_version ||= ENV['MEMONITE_VERSION'] || memonite_version_from_file
    end
  end

  def memonite_version_from_file
    File.read(Rails.root.join('VERSION').to_s).strip
  end
end
