Sequel.migration do
  change do
    add_index(:databases, :heroku_id, unique: true)
  end
end