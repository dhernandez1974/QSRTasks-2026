require 'csv'

module Datapass
  class DatapassWebhookRouterJob < ApplicationJob
    queue_as :default

    def perform(inbound_webhook, content_type)
      webhook_payload = JSON.parse(inbound_webhook.body, symbolize_names: true)
      filename = webhook_payload[:filename]
      filename_regex = /^(\d{7})_([^_]+)_([^_]+)_([^_]+)_([^_]+)_(\d{8}\d{6}\d{3})_([^_]+)\.(csv|json|xml|psv)\.enc$/
      # Will use information below to determine how to process data once it is decrypted
      if filename.match?(filename_regex)
        nsn, data_source, topic, topic_id, version, timestamp, mcopco_or_eid, filetype = filename.match(filename_regex).captures
      else
        puts "Filename does not match the expected format."
      end

      case content_type
      when 'application/x-www-form-urlencoded' #Data sent directly to QSRTasks - Still need to work on this
        data = webhook_payload[:data]
        b64_hash = process_and_create_files(data) if data
      when 'application/json' #Filename sent to retrieve data from AWS
        b64_hash = retrieve_file_from_s3(filename) #Get file from AWS & split into 3 separate hashes in a hash
      when 'application/psv'
        b64_hash = retrieve_file_from_s3(filename) #Get file from AWS & split into 3 separate hashes in a hash
      else
        # puts "DID NOT READ CONTENT TYPE"
      end

      enc_hash = decode_base64_in_memory(b64_hash) # decode base64 data in each file
      unless verify_openssl_signature(enc_hash) # verify signature on passphrase.enc.signed
        # puts 'Signature verification failed'
        return
      end
      passphrase = decrypt_passphrase(enc_hash) # decrypt passphrase
      if passphrase.nil?
        # puts 'Passphrase decryption failed'
        return
      end

      payload_file = decrypt_payload(passphrase, enc_hash[:payload_json_enc_b64], filetype)
      if payload_file.nil?
        # puts'Payload decryption failed'
        return
      end

      case topic
      when 'LZ-HR-Personal'
        Datapass::LifelenzPersonalJob.perform_later(payload_file, nsn, timestamp)
      when 'eR-HR-IdMgmtFull'
        Datapass::IdmgmtJob.perform_later(payload_file, nsn, timestamp)
      when 'LZ-HR-IdMgmtFull'
        Datapass::LifelenzIdmgmtJob.perform_later(payload_file, nsn, timestamp)
      when 'eR-HR-SSN'
        Datapass::GeidMatchJob.perform_later(payload_file, nsn, timestamp)
      when 'LZ-HR-SSN'
        Datapass::GeidMatchJob.perform_later(payload_file, nsn, timestamp)
      when 'eR-HR-Identification'
        Datapass::IdentificationJob.perform_later(payload_file, nsn, timestamp)
      when 'LZ-HR-Identification'
        Datapass::LifelenzIdentificationJob.perform_later(payload_file, nsn, timestamp)
      when 'eR-HR-IdMgmt'
        Datapass::IdmgmtJob.perform_later(payload_file, nsn, timestamp)
      when 'LZ-HR-IdMgmt'
        Datapass::LifelenzIdmgmtJob.perform_later(payload_file, nsn, timestamp)
      when 'HR-EmployeeDetails'
        Datapass::EmployeeDetailsJob.perform_later(payload_file, nsn, timestamp)
      when 'eR-LSCHD-Projections'

      when 'eR-LSCHD-Schedule'
            #WeeklyScheduleJob.perform_later(payload_file, nsn.to_i, timestamp)
      when 'eR-TIME-LAB'

      when 'eR-TIME-DAR'

      when 'McHire-HIRE-New'
        Datapass::MchireNewHireJob.perform_later(payload_file, nsn, timestamp)

      when 'McHIRE-ApplicantData'

      when 'SKILLLEVEL'

      when 'USAGE'

      when 'OTP-ACCREDITATION-FULL'

      when 'OTP-ACCREDITATION-DELTA'

      when 'TrainingTracking'
        Datapass::TrainingTrackingJob.perform_later(payload_file, nsn, timestamp)
      when 'TrainingTrackingFull'
        Datapass::TrainingTrackingJob.perform_later(payload_file, nsn, timestamp)
      when 'INVY-DTSERVTIMES'
        Datapass::InvyDtservtimesJob.perform_later(payload_file, nsn, timestamp)
      when 'INVY-KVSTIMES'
        Datapass::InvyKvstimesJob.perform_later(payload_file, nsn, timestamp)
      when 'CASH-QtrHrSales'
        # Datapass::CashHourlySaleJob.perform_later(payload_file, nsn, timestamp)
      when 'CASH-HourlySales'
        # Datapass::CashHourlySaleJob.perform_later(payload_file, nsn, timestamp)
      when 'CASH-Delivery'
        Datapass::CashDeliveryJob.perform_later(payload_file, nsn, timestamp)
      when 'CASH-GMADeliveryDetails'
        # Datapass::CashDeliveryJob.perform_later(payload_file, nsn, timestamp)
      when 'LZ-LSCHD-Schedule'
        Datapass::LifelenzScheduleJob.perform_later(payload_file, nsn, timestamp)
      when 'LZ-TIME-Open'
        Datapass::LifelenzPayperiodJob.perform_later(payload_file, nsn, timestamp)
      when 'CASH-CashlessDetails'
        Datapass::CashlessDetailJob.perform_later(payload_file, nsn, timestamp)
      when 'CASH-OverOrShort'
        Datapass::CashOverShortJob.perform_later(payload_file, nsn, timestamp)
      when 'CASH-CashlessSummary'
        # Datapass::CashlessSummaryJob.perform_later(payload_file, nsn, timestamp)
      when 'CASH-CashSheet'
        Datapass::CashSheetJob.perform_later(payload_file, nsn, timestamp)
      when 'CASH-Deposits'
        Datapass::CashDepositJob.perform_later(payload_file, nsn, timestamp)
      when 'Invoices'
        Datapass::InvoiceJob.perform_later(payload_file, nsn, timestamp)
      when 'VoiceData'
        Datapass::VoiceDataJob.perform_later(payload_file, nsn, timestamp)
      else
        inbound_webhook.update(status: :processed)
      end

      # DatapassMailer.send_email_with_attachment('dhernandez@staggrp.com',"#{data_source}-#{topic}-#{DateTime.strptime(timestamp, "%Y%m%d%H%M")}",
      # "File delivered for #{nsn}", payload_file, "#{nsn}-#{data_source}-#{topic}.json").deliver_now
      #
      #Once payload file is successful, send to other jobs to process data and update models!!
      inbound_webhook.update(status: :processed)
    rescue JSON::ParserError => e
      puts "JSON PARSE ERROR IN HOOK"
    end

    private

    def process_and_create_files(data)
      passphrase_enc_b64, payload_json_enc_b64, passphrase_enc_signed_b64 = data.split('.')
      {passphrase_enc_b64: passphrase_enc_b64, payload_json_enc_b64: payload_json_enc_b64, passphrase_enc_signed_b64: passphrase_enc_signed_b64}
    end

    def s3_client
      @s3_client ||= Aws::S3::Client.new(
        region: Rails.application.credentials.dig(:aws_datapass, :region),
        credentials: Aws::Credentials.new(
          Rails.application.credentials.dig(:aws_datapass, :access_key_id),
          Rails.application.credentials.dig(:aws_datapass, :secret_access_key)
        )
      )
    end

    def retrieve_file_from_s3(filename)
      bucket = Rails.application.credentials.dig(:aws_datapass, :bucket_name)
      # Retrieve the file from S3
      s3_filename = "prod/#{filename}"
      resp = s3_client.get_object(bucket: bucket, key: s3_filename)
      passphrase_enc_b64, payload_json_enc_b64, passphrase_enc_signed_b64 = resp.body.read.split('.')
      { passphrase_enc_b64: passphrase_enc_b64, payload_json_enc_b64: payload_json_enc_b64, passphrase_enc_signed_b64: passphrase_enc_signed_b64 }
    end

    def decode_base64_in_memory(b64_hash)
      enc_hash = {}
      b64_hash.each do |key, value|
        enc_hash[key] = Base64.decode64(value)
      end
      enc_hash
    end

    def verify_openssl_signature(files)
      public_key = OpenSSL::PKey::RSA.new(Rails.application.credentials.dig(:datapass, :public_key))
      digest = OpenSSL::Digest::SHA256.new
      passphrase = files[:passphrase_enc_b64]
      signed_passphrase = files[:passphrase_enc_signed_b64]
      public_key.verify(digest, signed_passphrase, passphrase)
    end

    def decrypt_passphrase(files)
      enc_passphrase = files[:passphrase_enc_b64]
      pem_password = Rails.application.credentials.dig(:datapass, :pem_password)
      private_key = OpenSSL::PKey::RSA.new(Rails.application.credentials.dig(:datapass, :private_key), pem_password)
      begin
        decrypted_passphrase = private_key.private_decrypt(enc_passphrase)
      rescue OpenSSL::PKey::RSAError => e
        puts "Decryption failed: #{e.message}"
      end
      decrypted_passphrase
    end

    def decrypt_payload(passphrase, encrypted_payload, filetype)
      # Replicating openssl enc -d -aes-256-cbc -pbkdf2
      # OpenSSL's pbkdf2 with default salt and iterations for CLI
      # Salted__ is the header (8 bytes) followed by 8 bytes of salt
      if encrypted_payload.start_with?("Salted__")
        salt = encrypted_payload[8...16]
        data_to_decrypt = encrypted_payload[16..]
      else
        # If no salt, we might have issues with -pbkdf2 which expects it, but let's handle if possible
        salt = nil
        data_to_decrypt = encrypted_payload
      end

      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.decrypt

      # For -pbkdf2, we need to derive key and IV using PBKDF2
      # iterations default to 10000 in newer OpenSSL for pbkdf2
      # digest defaults to sha256
      iterations = 10000
      digest = OpenSSL::Digest.new('sha256')

      key_iv = OpenSSL::PKCS5.pbkdf2_hmac(passphrase, salt, iterations, cipher.key_len + cipher.iv_len, digest)
      cipher.key = key_iv[0, cipher.key_len]
      cipher.iv = key_iv[cipher.key_len, cipher.iv_len]

      begin
        decrypted_data = cipher.update(data_to_decrypt) + cipher.final
      rescue OpenSSL::Cipher::CipherError => e
        puts "Decryption failed: #{e.message}"
        return nil
      end

      case filetype
      when "json"
        begin
          JSON.parse(decrypted_data)
        rescue JSON::ParserError => e
          puts "JSON parse error: #{e.message}"
          decrypted_data
        end
      when "csv"
        decrypted_data
      when "psv"
        CSV.generate do |csv|
          decrypted_data.each_line do |line|
            csv << line.strip.split("|")
          end
        end
      when "xml"
        doc = Nokogiri::XML(decrypted_data)
        JSON.pretty_generate(node_to_hash(doc.root))
      else
        decrypted_data
      end
    end

    def node_to_hash(node)
      if node.element?
        result_hash = {}
        node.attributes.each do |key, attr|
          result_hash[key] = attr.value
        end
        node.children.each do |child|
          result = node_to_hash(child)
          if child.name == "text"
            unless child.next_sibling || child.previous_sibling
              return result
            end
          elsif result_hash[child.name]
            if result_hash[child.name].is_a?(Array)
              result_hash[child.name] << result
            else
              result_hash[child.name] = [result_hash[child.name], result]
            end
          else
            result_hash[child.name] = result
          end
        end
        result_hash
      else
        node.content.to_s
      end
    end
  end
end
