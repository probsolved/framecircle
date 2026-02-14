# Puma configuration file
# See https://puma.io/puma/Puma/DSL.html

# Thread configuration
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Port (Render provides PORT)
port ENV.fetch("PORT", 3000)

# IMPORTANT:
# On Render free tier with ActiveStorage Disk service,
# running multiple workers will cause uploaded files
# to be unavailable to other requests (404s).
#
# Force single-process mode in production.
if ENV["RAILS_ENV"] == "production"
  workers 0
end

# Allow `bin/rails restart` to work
plugin :tmp_restart

# ❌ Do NOT run Solid Queue inside Puma on Render free tier
# (it requires DB tables + worker semantics you don't have yet)
# plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Optional PID file
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
