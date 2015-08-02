json.array!(@usuario_sitios) do |usuario_sitio|
  json.extract! usuario_sitio, :id, :idUsuarioSitio, :idUsuarioS, :idSitioU
  json.url usuario_sitio_url(usuario_sitio, format: :json)
end
