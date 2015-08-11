#!/usr/bin/ruby
require 'net/https'
require 'json'

atlas_artifact = ENV['TF_VAR_atlas_artifact_master']
atlas_artifact_version = ENV['TF_VAR_atlas_artifact_version_master']

artifact_url = "https://atlas.hashicorp.com/api/v1/artifacts/"+atlas_artifact+"/aws.ami/search?version="+atlas_artifact_version
uri = URI.parse(artifact_url)

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

request = Net::HTTP::Get.new(uri.request_uri)
request['X-Atlas-Token'] = ENV['ATLAS_TOKEN']

response = http.request(request).body
data = JSON.parse(response)

regions = {}
region_prefix = /^region./

data['versions'].each {|key, value|
  metadata = key['metadata']

  metadata.each { |k,v|
	if k.match(region_prefix)
	  k = k.gsub(region_prefix, '')
	  regions[k] = v
	end
  }
}

output = {
  "variable" => {
    "all_amis" => {
      "description" => "The AMI to use",
      "default" => regions
    }
  }
}

puts JSON.pretty_generate(output)
