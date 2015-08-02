json.array!(@sitios) do |sitio|
  json.extract! sitio, :id, :idSitio, :latitude, :longitude, :nombre, :fecha
  json.url sitio_url(sitio, format: :json)
end
