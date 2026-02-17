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

  if ip
    Rails.logger.info("[smtp_dns_retry] resolved #{host} -> #{ip}; using IP for SMTP socket")
    settings[:tls_hostname] ||= host
    settings[:address] = ip
  end
end
