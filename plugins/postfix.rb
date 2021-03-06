Ohai.plugin(:Postfix) do
  provides 'postfix'
 
  depends 'packages'

 
  def find_postfix_executable
    so = shell_out("/bin/bash -c 'command -v postfix'")
    postfix_bin = so.stdout.strip
    return postfix_bin unless postfix_bin.empty?
  end

  def find_postfix_process
    unless @postfix_process
      postfix_process = {}
      so = shell_out("ps aux | grep [m]aster | awk '{print $2 \", \"$11}' ")
      if !so.stdout.empty?
        ps_output = so.stdout.split(', ')
        postfix_process = { "Master Process PID" => ps_output[0].chomp,
                            "Master Process" => ps_output[1].chomp}
      else
        postfix_process = {"Master Process" => 'Postfix is not running!'}
      end
    end
    return postfix_process
  end

  def check_postfix_configuration
    postconf={}
    response={}
    configuration_files={}

    importantKeys = {
      "inet_interfaces" => "Postfix Listening On Addresses",
      "inet_protocols" => "IP protocols in use",
      "myhostname" => "Postfix Hostname",
      "mydomain" => "Postfix Domain Name",
      "mydestination" => "Postfix Final Destinations",
      "mynetworks" => "Postfix Trusted Client Networks",
      "myorigin" => "Postfix Origin Address",
      "alias_database" => "Postfix Aliases Database",
      "config_directory" => "Postfix Configuration Directory"
    }
      
    postconfOutput = shell_out('postconf')

    postconfOutput.stdout.lines do |line|
      fields = line.split(' = ')
      if fields[1]
        postconf[fields[0]] = fields[1].strip
      end
    end

    importantKeys.each do |key, value|
      response[value] = postconf[key]
    end
    response[:"Postfix Configuration Files"] = Dir.glob(postconf['config_directory']+"/*")
   
    return response
  end  


  collect_data(:linux) do
    if postfix_binary = find_postfix_executable
      postfix Mash.new
      postfix[:postfix_binary] = postfix_binary
      postfix[:postfix_package] = packages[:postfix]
      postfix[:process] = find_postfix_process
      postfix[:current_configuration] = check_postfix_configuration
    end  
  end
end
