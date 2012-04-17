Nori.configure do |config|
  config.parser = :nokogiri
  config.strip_namespaces = true
  config.convert_tags_to { |tag| tag.snakecase.to_sym }
end