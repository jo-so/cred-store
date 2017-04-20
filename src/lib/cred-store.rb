# todo: Passwortabfrage /usr/share/doc/ruby-gpgme/examples/roundtrip.rb

unless ENV['GPG_AGENT_INFO']
    $stderr.puts "gpg-agent is not running.  See the comment in #{$0}."
    exit 1
end

require 'gpgme'
require 'yaml'

class CredStore
    def self.setup_key
        # gpg --quick-gen-key cred-store future-default default never
    end

    def init
        # gpg --no-encrypt-to --default-key cred-store --encrypt passwd
    end

    def initialize(file_name = nil)
        file_name ||= ENV['HOME'] + '/passwd.gpg'
        file = File.open file_name

        yaml_data = GPGME::Crypto.new.decrypt(file).read

        @data = YAML.load_stream(yaml_data, file_name).first.inject({}) do |hsh, el|
            next hsh if el['ignore']

            if el.has_key? 'key'
                hsh[el['key']] = el
            else
                hsh[el['site']] = el if el.has_key? 'site'
                hsh[el['username'] + '@' + el['hostname']] = el if el.has_key? 'hostname'
            end
            hsh
        end
    end

    def [](key)
        $stderr.puts "Looking for " + key
        @data[key]
    end
end
