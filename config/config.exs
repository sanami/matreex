import Config

env_file = Path.expand "#{config_env()}.exs", __DIR__
if File.exists?(env_file), do: import_config(env_file)
