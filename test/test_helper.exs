Application.ensure_all_started(:mimic)
Mimic.copy(HTTPoison)
ExUnit.start()
