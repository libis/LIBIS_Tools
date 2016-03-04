# encoding: utf-8

require 'libis/tools/metadata/mappers/kuleuven'

module Libis
  module Tools
    module Metadata
      module Mappers

        # noinspection RubyResolve

        # Mixin for {::Libis::Tools::Metadata::MarcRecord} to enable conversion into
        # {Libis::Tools::Metadata::DublinCoreRecord}. This module implements the conversion mapping for Flandrica by
        # extending the version for {::Libis::Tools::Metadata::Mappers::Kuleuven KU Leuven} and overwriting what's
        # different. This means any change to the KU Leuven mapping may have effect on this mapping as well.
        module Flandrica
          extend Libis::Tools::Metadata::Mappers::Kuleuven

          protected

          def marc2dc_identifier(xml)
            Libis::Tools::Metadata::Mappers::Kuleuven.marc2dc_identifier(xml)
            marc2dc_identifier_040(xml)
          end

          def marc2dc_identifier_001(xml)
            # "urn:ControlNumber:" [MARC 001]
            tag('001').each { |t|
              xml['dc'].identifier element(t.datas, prefix: '')
            }
          end

          def marc2dc_identifier_040(xml)
            # [MARC 040 $a]
            tag('040', 'a').each { |t|
              xml['dc'].identifier('xsi:type' => 'dcterms:URI').text t._a
            }
          end

          def marc2dc_alternative_240_a(xml)
            # [MARC 240 #_ $a] ", " [MARC 240 #_ $f] ", " [MARC 240 #_ $g] ", "
            tag('240#_', 'a f g').each { |t|
              xml['dcterms'].alternative element(t._afg, join: ', ', postfix: ', ')
            }
          end

          def marc2dc_alternative_240_l(xml)
            # [MARC 240 #_ $l] ", " [MARC 240 #_ $m] ", " [MARC 240 #_ $n] ", " [MARC 240 #_ $o] ", " [MARC 240 #_ $p] ", " [MARC 240 #_ $r] ", " [MARC 240 #_ $s]
            tag('240#_', 'l m n o p r s').each { |t|
              xml['dcterms'].alternative element(t._lmnoprs, join: ', ')
            }
          end

          def marc2dc_source_856(xml)
            marc2dc_source_856__1(xml)
            marc2dc_source_856__2(xml)
            marc2dc_source_856___(xml)
          end

          def marc2dc_source_856___(xml)
            # [MARC 856 ## $a]
            tag('856', 'a').each { |t|
              xml['dc'].source('xsi:type' => 'dcterms:URI').text element(t._a)
            }
          end

          def check_name(_,_)
            true
          end

        end

      end
    end
  end
end
