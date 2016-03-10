# Need a Phantom polyfill, there is a docs and js path, order is not guaranteed, so just append both
RailsAssetsEs5Shim.load_paths.each { |p| Opal.append_path p }
RailsAssetsJquery.load_paths.each { |p| Opal.append_path p }
RailsAssetsReact.load_paths.each { |p| Opal.append_path p }
