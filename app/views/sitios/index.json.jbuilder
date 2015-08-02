fec.array!(@sitios) do |sitio|
  json.extract! sitio, :id, :idSitio, :latitude, :longitude, :nombre
  json.url sitio_url(sitio, format: :json)
end
