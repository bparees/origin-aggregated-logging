# encoding: UTF-8

# This file contains data derived from the IANA Time Zone Database
# (http://www.iana.org/time-zones).

module TZInfo
  module Data
    module Definitions
      module Europe
        module Belfast
          include TimezoneDefinition
          
          linked_timezone 'Europe/Belfast', 'Europe/London'
        end
      end
    end
  end
end
