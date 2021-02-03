# parses status of configured omd sites
# sample output of `/usr/bin/omd status -b`:
#   [ref]
#   mkeventd 0
#   mknotifyd 0
#   rrdcached 0
#   cmc 0
#   apache 0
#   xinetd 0
#   crontab 0
#   OVERALL 0
#   [tester]
#   mkeventd 1
#   liveproxyd 1
#   mknotifyd 1
#   rrdcached 1
#   cmc 1
#   apache 1
#   crontab 1
#   OVERALL 1
#
# creates hash:
# {"ref"=>{"mkeventd"=>"0", "mknotifyd"=>"0", "rrdcached"=>"0", "cmc"=>"0", "apache"=>"0", "xinetd"=>"0", "crontab"=>"0", "OVERALL"=>"0"}, "tester"=>{"mkeventd"=>"1", "liveproxyd"=>"1", "mknotifyd"=>"1", "rrdcached"=>"1", "cmc"=>"1", "apache"=>"1", "crontab"=>"1", "OVERALL"=>"1"}}

require 'facter'

Facter.add("omdsites") do
  setcode do
    distid = Facter.value(:lsbdistid)
    case distid
    when /Ubuntu/
      if !Facter::Util::Resolution.exec("/usr/bin/dpkg -l | /bin/grep check-mk-enterprise && /usr/bin/which omd").empty?
        omdstats = Facter::Util::Resolution.exec("/usr/bin/omd status -b")
        omd_hash = {}
        current_site_name = ""
        current_site_hash = {}
        omdstats.split("\n").each do |line|
          if line =~ /^\[(.*)\]$/
            if !current_site_hash.empty? and !current_site_name.empty?
              omd_hash[current_site_name.clone] = current_site_hash.clone
            end
            current_site_name = $1
            current_site_hash = {}
          elsif line =~ /([\w]+)\s+([\d]+)/
            current_site_hash[$1] = $2
          end
        end
        if !current_site_hash.empty? and !current_site_name.empty?
          omd_hash[current_site_name.clone] = current_site_hash.clone
        end
        omd_hash
      end
    when /RedHatEnterprise|CentOS|Fedora/
      if !Facter::Util::Resolution.exec("/usr/bin/rpm -qa | /bin/grep check-mk-enterprise && /usr/bin/which omd").empty?
        omdstats = Facter::Util::Resolution.exec("/usr/bin/omd status -b")
        omd_hash = {}
        current_site_name = ""
        current_site_hash = {}
        omdstats.split("\n").each do |line|
          if line =~ /^\[(.*)\]$/
            if !current_site_hash.empty? and !current_site_name.empty?
              omd_hash[current_site_name.clone] = current_site_hash.clone
            end
            current_site_name = $1
            current_site_hash = {}
          elsif line =~ /([\w]+)\s+([\d]+)/
            current_site_hash[$1] = $2
          end
        end
        if !current_site_hash.empty? and !current_site_name.empty?
          omd_hash[current_site_name.clone] = current_site_hash.clone
        end
        omd_hash
      end
    else
    end
  end
end
