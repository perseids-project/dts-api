ActionController::Renderers.add :epub do |obj, options|
  filename = options[:filename] || 'data'
  str = obj.respond_to?(:to_csv) ? obj.to_epub : obj.to_s
  send_data str, type: Mime[:epub], disposition: "attachment; filename=#{filename}.epub"
end
