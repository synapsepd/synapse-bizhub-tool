require 'net/http'

module BizhubTool    
    class Client
      
    attr_accessor :auth_key, :url, :username, :password, :lock_key

    def initialize(url, username, password)
      self.url = URI.parse(url)
      self.username = username
      self.password = password
      if self.confirm_connect
        if self.login
          true
        else
          raise ArgumentError, "user/name password invalid"
        end
      else
        raise ArgumentError, "unable to connect"
      end
    end
  
    def confirm_connect
      # url = URI.parse('http://geoffrey.synapsedev.com:50001/')
      request = Net::HTTP::Post.new(self.url.path)
      body =<<-TEXT
      <AppReqConfirmConnect xmlns="http://www.konicaminolta.com/service/OpenAPI-4-2"><OperatorInfo><UserType>#{self.username}</UserType><Password>#{self.password}</Password></OperatorInfo></AppReqConfirmConnect>
      TEXT
      request.body = self.class.generate_request(body)
      response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
      response.body
      response_hash = Nori.parse(response.body)
      request_hash = Nori.parse(request.body)
      puts response_hash
      log_response(response_hash, request.body, "app_res_confirm_connect", __method__)
    end

    def login
      request = Net::HTTP::Post.new(self.url.path)
      body =<<-TEXT
      <AppReqLogin xmlns="http://www.konicaminolta.com/service/OpenAPI-4-2"><OperatorInfo><UserType>#{self.username}</UserType><Password>#{self.password}</Password></OperatorInfo><TimeOut>60</TimeOut></AppReqLogin>
      TEXT
      request.body = self.class.generate_request(body)
      puts request.body
      response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
      response.body
      response_hash = Nori.parse(response.body)
      if log_response(response_hash, request.body, "app_res_login", __method__)
        self.auth_key = response_hash[:envelope][:body][:app_res_login][:auth_key]
        true
      else
        false
      end
    end


    def enter_device_lock
      request = Net::HTTP::Post.new(self.url.path)
      body =<<-TEXT
      <AppReqEnterDeviceLock xmlns="http://www.konicaminolta.com/service/OpenAPI-4-2"><OperatorInfo><AuthKey>#{self.auth_key}</AuthKey></OperatorInfo><LockType>DownloadLock</LockType><PackageEntryFlg>Package</PackageEntryFlg><TimeOut>60</TimeOut></AppReqEnterDeviceLock>
      TEXT
      request.body = self.class.generate_request(body)
      response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
      response.body
      response_hash = Nori.parse(response.body)
      if log_response(response_hash, request.body, "app_res_enter_device_lock", __method__)
        self.lock_key = response_hash[:envelope][:body][:app_res_enter_device_lock][:lock_key]
        true
      else
        false
      end
    end

    def exit_device_lock
      request = Net::HTTP::Post.new(self.url.path)
      body =<<-TEXT
      <AppReqExitDeviceLock xmlns="http://www.konicaminolta.com/service/OpenAPI-4-2"><OperatorInfo><AuthKey>#{self.auth_key}</AuthKey></OperatorInfo><LockKey>#{self.lock_key}</LockKey></AppReqExitDeviceLock>
      TEXT
      request.body = self.class.generate_request(body)
      response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
      response_hash = Nori.parse(response.body)
      log_response(response_hash, request.body, "app_res_exit_device_lock", __method__)
    end

    def set_abbr(first_name, last_name, email, abbr_no)
      search_key = self.class.find_search_key(last_name)
      full_name = [first_name, last_name].join(" ")
      request = Net::HTTP::Post.new(self.url.path)
      body =<<-TEXT
      <AppReqSetAbbr xmlns="http://www.konicaminolta.com/service/OpenAPI-4-2"><OperatorInfo><AuthKey>#{self.auth_key}</AuthKey></OperatorInfo><CreateCondition><Auto>false</Auto><OverWrite>true</OverWrite></CreateCondition><LockKey>#{self.lock_key}</LockKey><Abbr xmlns:m="http://www.konicaminolta.com/service/OpenAPI-4-2"><AbbrNo>#{abbr_no}</AbbrNo><Name>#{full_name}</Name><SearchKey>#{search_key}</SearchKey><WellUse>false</WellUse><SendConfiguration><SendGroup>Scan</SendGroup><TargetAddressType>Single</TargetAddressType><AddressInfo><SendMode>Email</SendMode><EmailMode><To>#{email}</To></EmailMode><ImageType>Icon</ImageType><IconID>1</IconID><PhotoEditFlag>NotRegistered</PhotoEditFlag></AddressInfo></SendConfiguration><FaxConfiguration /><EditFlag>Appended</EditFlag><ReferLicence><UseReferLicence>Level</UseReferLicence><ReferGroupNo>1</ReferGroupNo><ReferPossibleLevel>0</ReferPossibleLevel></ReferLicence><AddressKind>Public</AddressKind></Abbr></AppReqSetAbbr>
      TEXT
      request.body = self.class.generate_request(body)
      response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
      response_hash = Nori.parse(response.body)
      log_response(response_hash, request.body, "app_res_set_abbr", __method__)
    end

    def get_abbr(start, length)
      request = Net::HTTP::Post.new(self.url.path)
      body =<<-TEXT
      <AppReqGetAbbr xmlns="http://www.konicaminolta.com/service/OpenAPI-4-2"><OperatorInfo><AuthKey>#{self.auth_key}</AuthKey></OperatorInfo><AbbrListCondition><SearchKey>None</SearchKey><WellUse>false</WellUse><ObtainCondition><Type>OffsetList</Type><OffsetRange><Start>#{start}</Start><Length>#{length}</Length></OffsetRange></ObtainCondition><BackUp>true</BackUp><BackUpPassword>MYSKIMGS</BackUpPassword></AbbrListCondition></AppReqGetAbbr>
      TEXT
      request.body = self.class.generate_request(body)
      response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
      response_hash = Nori.parse(response.body)
      if log_response(response_hash, request.body, "app_res_get_abbr", __method__)
        response_hash
      else
        false
      end
    end

    def delete_abbr(abbr_no)
      request = Net::HTTP::Post.new(self.url.path)
      body =<<-TEXT
      <AppReqDeleteAbbr xmlns="http://www.konicaminolta.com/service/OpenAPI-4-2"><OperatorInfo><AuthKey>#{self.auth_key}</AuthKey></OperatorInfo><LockKey>#{self.lock_key}</LockKey><AllItem>false</AllItem><AddressKind>Public</AddressKind><AbbrNo>#{abbr_no}</AbbrNo></AppReqDeleteAbbr>
      TEXT
      request.body = self.class.generate_request(body)
      response = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
      response_hash = Nori.parse(response.body)
      log_response(response_hash, request.body, "app_res_delete_abbr", __method__)
    end

    def get_max_abbr
      array_size = 100
      start_value = 1
      results = true
  
      while results == true
        puts start_value
        response = self.get_abbr(start_value, array_size)
        if response[:envelope][:body][:app_res_get_abbr][:abbr_list][:array_size].to_i == array_size
          start_value += array_size
        else
          results = false
          max_abbr = response[:envelope][:body][:app_res_get_abbr][:abbr_list][:abbr].last[:abbr_no]
        end
      end
      max_abbr
    end

    private

    def self.find_search_key(string)
      search_keys = ['Abc', 'Def', 'Ghi', 'Jkl', 'Mno', 'Pqrs', 'Tuv', 'Wxyz']
      search_key = nil
  
      search_keys.each do |k|
        if k.downcase.scan(string[0,1].downcase).count > 0
          search_key = k
        end
      end
  
      if search_key
        search_key
      else
        raise ArgumentError, "unable to get a search key"
      end
    end

    def self.determine_status(response_hash, method)
      if response_hash[:envelope][:body][method.to_sym][:result][:result_info] == 'Ack'
        'SUCCESS'
      elsif response_hash[:envelope][:body][method.to_sym][:result][:result_info] == 'Nack'
        'NO SUCCESS'
      end
    end

    def self.generate_request(body)
      request =<<-TEXT 
      <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><SOAP-ENV:Header><me:AppReqHeader xmlns:me="http://www.konicaminolta.com/Header/OpenAPI-4-2"><ApplicationID xmlns="">0</ApplicationID><UserName xmlns=""></UserName><Password xmlns=""></Password><Version xmlns=""><Major>4</Major><Minor>2</Minor></Version><AppManagementID xmlns="">1000</AppManagementID></me:AppReqHeader></SOAP-ENV:Header><SOAP-ENV:Body>
      TEXT
      request += body
      request += "</SOAP-ENV:Body></SOAP-ENV:Envelope>"
      request
    end

    def self.log_debug(url, action, status, request, response)
      RedisLogger.debug({ 
       "url" => url,
       "class::method" => action,
       "status" => status,
       "request" => request,
       "response" => response
      }, ['bizhub'])
    end

    def self.log_error(url, action, status, request, response)
      RedisLogger.error({ 
       "url" => url,
       "class::method" => action,
       "status" => status,
       "request" => request,
       "response" => response
      }, ['bizhub'])
    end

    def log_response(response_hash, request, api_method, class_method)
      if response_hash[:envelope][:body][:fault]
        self.class.log_error(self.url, get_class_method(class_method), 'ERROR', 
          Nori.parse(request), response_hash
        )
        false
      else
        self.class.log_debug(self.url, get_class_method(class_method), 
          self.class.determine_status(response_hash, api_method), 
          Nori.parse(request), response_hash
        )
        true
      end
    end

    def get_class_method(method)
      self.class.name + '::' + method.to_s
    end  
  end

end