# encoding: utf-8

require 'libis/tools/metadata/dublin_core_record'
require 'libis/tools/assert'

module Libis
  module Tools
    module Metadata
      module Mappers
        # noinspection RubyResolve

        # Mixin for {::Libis::Tools::Metadata::DublinCoreRecord} to enable conversion of the Scope exported DC record.
        module Scope

          # Main conversion method.
          # @return [::Libis::Tools::Metadata::DublinCoreRecord]
          def to_dc
            assert(self.is_a? Libis::Tools::Metadata::DublinCoreRecord)

            doc = Libis::Tools::Metadata::DublinCoreRecord.new(self.to_xml)

            # add URI annotation
            doc.isPartOf['xsi:type'] = 'dcterms:URI'

            # rename isPartOf to isReferencedBy
            doc.isPartOf.name = 'isReferencedBy'

            doc

          end

        end

      end
    end
  end
end
