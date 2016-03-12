APPEND = [RailsAssetsEs5Shim, RailsAssetsJquery, RailsAssetsReact]

APPEND.each do |rails_asset|
  rails_asset.load_paths.each { |p| Opal.append_path p }
end
