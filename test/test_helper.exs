Application.ensure_all_started(:mimic)
Mimic.copy(HTTPoison)
ExUnit.configure(exclude: [external: true])
ExUnit.start()
