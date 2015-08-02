json.array!(@usuario_gustos) do |usuario_gusto|
  json.extract! usuario_gusto, :id, :idUsuarioGusto, :idGustoU, :idUsuarioG
  json.url usuario_gusto_url(usuario_gusto, format: :json)
end
