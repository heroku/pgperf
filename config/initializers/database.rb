Sequel.extension :pg_array, :pg_array_ops
DB = Sequel.connect(Config.database_url, max_connections: Config.db_pool)
DB.extension :pg_array, :pg_json
