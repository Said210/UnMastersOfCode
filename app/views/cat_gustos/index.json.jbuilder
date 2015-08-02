json.array!(@cat_gustos) do |cat_gusto|
  json.extract! cat_gusto, :id, :idGusto, :gusto
  json.url cat_gusto_url(cat_gusto, format: :json)
end
