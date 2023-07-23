import Config

config :matreex, start_app: false

config :logger,
  compile_time_purge_matching: [[level_lower_than: :info]]
