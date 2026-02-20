# config/initializers/smtp_dns_retry.rb
# NOTE:
# Do NOT replace SMTP hostname with an IP in production.
# TLS certs are issued for hostnames, so connecting by IP breaks verification.

if Rails.env.development? || Rails.env.test?
  require "resolv"

  Rails.application.config.to_prepare do
    settings = Rails.application.config.action_mailer.smtp_settings
    next unless settings.is_a?(Hash)

    host = settings[:address]
    next unless host.is_a?(String) && host.include?(".")

    tries = 4
    delay = 0.5
    ip = nil

    tries.times do |i|
      begin
        ip = Resolv.getaddress(host)
        break
      rescue Resolv::ResolvError => e
        Rails.logger.warn("[smtp_dns_retry] resolve failed (#{i + 1}/#{tries}) for #{host}: #{e.class}: #{e.message}")
        sleep(delay)
        delay *= 2
      end
    end

    # In dev/test you may choose to log the resolution, but do NOT swap address to IP.
    if ip
      Rails.logger.info("[smtp_dns_retry] resolved #{host} -> #{ip} (dev/test only; not using IP for SMTP)")
      # Do NOT do: settings[:address] = ip
    end
  end
end
