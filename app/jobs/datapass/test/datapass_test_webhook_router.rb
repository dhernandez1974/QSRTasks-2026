class DatapassTestWebhookRouter < ApplicationJob
  queue_as :default

  def perform(inbound_webhook, content_type)
    webhook_payload = JSON.parse(inbound_webhook.body, symbolize_names: true)

    filename = webhook_payload[:filename]
    filename_regex = /^(\d{7})_([^_]+)_([^_]+)_([^_]+)_([^_]+)_(\d{8}\d{6}\d{3})_([^_]+)\.json\.enc$/

    # Will use information below to determine how to process data once it is decrypted
    if filename.match?(filename_regex)
      nsn, data_source, topic, topic_id, version, timestamp, mcopco_or_eid = filename.match(filename_regex).captures
    else
      puts "Filename does not match the expected format."
    end

    case content_type
    when 'application/x-www-form-urlencoded' #Data sent directly to QSRTasks - Still need to work on this
      data = webhook_payload[:data]
      b64_hash = process_and_create_files(data) if data
    when 'application/json' #Filename sent to retrieve data from AWS
      b64_hash = retrieve_file_from_s3(filename) #Get file from AWS & split into 3 separate hashes in a hash
    else
      puts "DID NOT READ CONTENT TYPE"
    end

    enc_hash = decode_base64(b64_hash) #decrypt base64 data in each file and save as encrypted data in a hash
    unless verify_openssl_signature(enc_hash) #verify signature on passphrase.enc.signed
      puts 'Signature verification failed'
      return
    end
    passphrase = decrypt_passphrase(enc_hash) #decrypt passphrase
    if passphrase.nil?
      puts 'Passphrase decryption failed'
      return
    end

    payload_file = decrypt_payload(passphrase, enc_hash[:payload_json_enc_b64])
    if payload_file.nil?
      puts'Payload decryption failed'
      return
    end

    DatapassMailer.send_email_with_attachment('dhernandez@staggrp.com',"#{data_source}-#{topic}-#{DateTime.strptime(timestamp, "%Y%m%d%H%M")}",
      "File delivered for #{nsn}", payload_file, "#{nsn}-#{data_source}-#{topic}.json").deliver_now

    case topic
    when 'eR-HR-IdMgmtFull'
      #TODO for this, work the data to update, add to users? no model needed
    when 'eR-HR-SSN'
      #TODO for this, work the data to update, add to users? no model needed
    when 'eR-HR-Identification'
      #TODO for this, work the data to update, add to users? no model needed
    when 'eR-HR-IdMgmt'
      #TODO for this, work the data to update, add to users? no model needed
    when 'eR-HR-IdMgmtFull'
      #TODO for this, work the data to update, add to users? no model needed
    when 'HR-EmployeeDetails'
      #TODO for this, work the data to update, add to users? no model needed
    when 'eR-LSCHD-Projections'

    when 'eR-LSCHD-Schedule'

    when 'eR-TIME-LAB'

    when 'eR-TIME-DAR'

    when 'McHIRE-HIRE-NEW'

    when 'McHIRE-ApplicantData'

    when 'SKILLLEVEL'

    when 'USAGE'

    when 'OTP-ACCREDITATION-FULL'

    when 'OTP-ACCREDITATION-DELTA'

    when 'TrainingTracking'

    when 'TrainingTrackingFull'

    when 'INVY-DTSERVTIMES'
      nsn = '0001480' #TODO remove in production
      #InvyDtservtimesJob.perform_later(payload_file, nsn, timestamp)
    when 'INVY-KVSTIMES'
      nsn = '0001480' #TODO remove in production
      puts payload_file
      #InvyKvstimesJob.perform_later(payload_file, nsn, timestamp)
    when 'CASH-QtrHrSales'

    when 'CASH-HourlySales'
      nsn = '0001480' #TODO remove in production
      #CashHourlySaleJob.perform_later(payload_file, nsn, timestamp)
    when 'CASH-Delivery'
      nsn = '0001480' #TODO remove in production
      #CashDeliveryJob.perform_later(payload_file, nsn, timestamp)
    when 'CASH-GMADeliveryDetails'

    when 'CASH-CashlessDetails'

    when 'CASH-CashlessSummary'

    else

    end
    #Once payload file is successful, send to other jobs to process data and update models!!
    inbound_webhook.update(status: :processed)
  rescue JSON::ParserError => e
    puts "JSON PARSE ERROR IN HOOK"
  end

  private

    def process_and_create_files(data)
      puts "HIT PROCESS AND CREATE FILES"
      passphrase_enc_b64, payload_json_enc_b64, passphrase_enc_signed_b64 = data.split('.')
      {passphrase_enc_b64: passphrase_enc_b64, payload_json_enc_b64: payload_json_enc_b64, passphrase_enc_signed_b64: passphrase_enc_signed_b64}
    end

    def retrieve_file_from_s3(filename)
      puts "HIT RETRIEVE FILE FROM S3"
      s3_client = Aws::S3::Client.new(region: Rails.application.credentials.dig(:aws_datapass, :region),
        credentials: Aws::Credentials.new(Rails.application.credentials.dig(:aws_datapass, :access_key_id),
          Rails.application.credentials.dig(:aws_datapass, :secret_access_key)))
      bucket = Rails.application.credentials.dig(:aws_datapass, :bucket_name)
      # Retrieve the file from S3
      s3_filename = "test/#{filename}"
      resp = s3_client.get_object(bucket: bucket, key: s3_filename)
      passphrase_enc_b64, payload_json_enc_b64, passphrase_enc_signed_b64 = resp.body.read.split('.')
      {passphrase_enc_b64: passphrase_enc_b64, payload_json_enc_b64: payload_json_enc_b64, passphrase_enc_signed_b64: passphrase_enc_signed_b64}
    end

    def decode_base64(b64_hash)
      enc_hash = {}
      b64_hash.each do |key, value|
        enc_hash[key] = Base64.decode64(value)
      end
      file_name = "#{rand(10000..1000000)}-payload.json.enc"
      directory_path = Rails.root.join('tmp', 'datapass')
      file_path = directory_path.join(file_name)
      FileUtils.mkdir_p(directory_path) unless Dir.exist?(directory_path)
      File.open(file_path, 'wb') do |file|
        file.write(enc_hash[:payload_json_enc_b64])
      end
      enc_hash[:payload_json_enc_b64] = file_path
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
      private_key = OpenSSL::PKey::RSA.new(Rails.application.credentials.dig(:datapass, :private_key))
      begin
        decrypted_passphrase = private_key.private_decrypt(enc_passphrase)
      rescue OpenSSL::PKey::RSAError => e
        puts "Decryption failed: #{e.message}"
      end
      decrypted_passphrase
    end

    def wait_for_file(file_path, timeout: 60, interval: 5)
      start_time = Time.now
      while Time.now - start_time < timeout
        return true if File.exist?(file_path)
        sleep(interval) # Wait for 'interval' seconds before the next check
      end
      false # Timeout reached, file not found
    end

    def decrypt_payload(passphrase, input_file)
      if wait_for_file(input_file)
        command = "openssl enc -d -aes-256-cbc -md md5 -in #{input_file} -pass pass:\"#{passphrase}\""
        stdout, stderr, status = Open3.capture3(command)
        if status.success?
          puts "Decryption successful!"
          File.delete(input_file)
          JSON.parse(stdout)
        else
          puts "Decryption failed: #{stderr}"
          nil
        end
      else
        puts "File not found within the specified timeout."
      end

    end

end
