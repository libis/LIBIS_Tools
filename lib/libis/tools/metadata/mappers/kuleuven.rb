# encoding: utf-8

require 'libis/tools/metadata/marc_record'
require 'libis/tools/metadata/dublin_core_record'
require 'libis/tools/assert'

module Libis
  module Tools
    module Metadata
      module Mappers
        # noinspection RubyResolve

        # Mixin for {::Libis::Tools::Metadata::MarcRecord} to enable conversion into
        # {Libis::Tools::Metadata::DublinCoreRecord}. This module implements the conversion mapping for KU Leuven.
        module Kuleuven

          # Main conversion method.
          # @param [String] label optional extra identified to add to the DC record.
          # @return [::Libis::Tools::Metadata::DublinCoreRecord]
          def to_dc(label = nil)
            assert(self.is_a? Libis::Tools::Metadata::MarcRecord)

            doc = Libis::Tools::Metadata::DublinCoreRecord.new do |xml|
              marc2dc_identifier(xml, label)
              marc2dc_title(xml)
              marc2dc_ispartof(xml)
              marc2dc_alternative(xml)
              marc2dc_creator(xml)
              marc2dc_subject(xml)
              marc2dc_temporal(xml)
              marc2dc_description(xml)
              marc2dc_isversionof(xml)
              marc2dc_abstract(xml)
              marc2dc_tableofcontents(xml)
              marc2dc_available(xml)
              marc2dc_haspart(xml)
              marc2dc_contributor(xml)
              marc2dc_provenance(xml)
              marc2dc_publisher(xml)
              marc2dc_date(xml)
              marc2dc_type(xml)
              marc2dc_spatial(xml)
              marc2dc_extent(xml)
              marc2dc_accrualperiodicity(xml)
              marc2dc_format(xml)
              marc2dc_medium(xml)
              marc2dc_relation(xml)
              marc2dc_replaces(xml)
              marc2dc_hasversion(xml)
              marc2dc_source(xml)
              marc2dc_language(xml)
              marc2dc_rightsholder(xml)
              marc2dc_references(xml)
              marc2dc_isreferencedby(xml)
              marc2dc_coverage(xml)

            end

            # deduplicate the XML
            found = Set.new
            doc.root.children.each { |node| node.unlink unless found.add?(node.to_xml) }

            doc

          end

          protected

          def marc2dc_identifier(xml, label = nil)
            # DC:IDENTIFIER
            marc2dc_identifier_label(label, xml)
            marc2dc_identifier_001(xml)
            marc2dc_identifier_035(xml)
            marc2dc_identifier_024_8(xml)
            marc2dc_identifier_028_4(xml)
            marc2dc_identifier_028_5(xml)
            marc2dc_identifier_029(xml)
            marc2dc_identifier_700(xml)
            marc2dc_identifier_710(xml)
            marc2dc_identifier_752(xml)
            marc2dc_identifier_020(xml)
            marc2dc_identifier_020_9(xml)
            marc2dc_identifier_022(xml)
            marc2dc_identifier_024_2(xml)
            marc2dc_identifier_024_3(xml)
            marc2dc_identifier_690(xml)
            marc2dc_identifier_856(xml)
          end

          def marc2dc_identifier_label(label, xml)
            # noinspection RubyResolve
            xml['dc'].identifier label if label
          end

          def marc2dc_identifier_001(xml)
            # "urn:ControlNumber:" [MARC 001]
            all_tags('001') { |t|
              xml['dc'].identifier element(t.datas, prefix: 'urn:ControlNumber:')
            }
          end

          def marc2dc_identifier_035(xml)
            # [MARC 035__ $a]
            each_field('035__', 'a') { |f| xml['dc'].identifier f }
          end

          def marc2dc_identifier_024_8(xml)
            # [MARC 24 8_ $a]
            each_field('0248_', 'a') { |f| xml['dc'].identifier f }
          end

          def marc2dc_identifier_028_4(xml)
            # [MARC 28 40 $b]": "[MARC 28 40 $a]
            all_tags('02840') { |t|
              xml['dc'].identifier element(t._ba, join: ': ')
            }
          end

          def marc2dc_identifier_028_5(xml)
            # [MARC 28 50 $b]": "[MARC 28 50 $a]
            all_tags('02850') { |t|
              xml['dc'].identifier element(t._ba, join: ': ')
            }
          end

          def marc2dc_identifier_029(xml)
            # "Siglum: " [MARC 029 __ $a]
            # each_field('029__', 'a') { |f| xml['dc'].identifier element(f, prefix: 'Siglum: ') }
            # ALMA: 029 __ a => 028 00 a
            each_field('02800', 'a') { |f| xml['dc'].identifier element(f, prefix: 'Siglum: ') }
          end

          def marc2dc_identifier_700(xml)
            # [MARC 700 #_ $0]
            each_field('700#_', '0') { |f| xml['dc'].identifier f }
          end

          def marc2dc_identifier_710(xml)
            # [MARC 710 #_ $0]
            each_field('710#_', '0') { |f| xml['dc'].identifier f }
          end

          def marc2dc_identifier_752(xml)
            # [MARC 752 __ $0]
            each_field('752__', '0') { |f| xml['dc'].identifier f }
          end

          def marc2dc_identifier_020(xml)
            # "urn:ISBN:"[MARC 020 __ $a]
            each_field('020__', 'a') { |f|
              xml['dc'].identifier('xsi:type' => 'dcterms:URI').text element(f, prefix: 'urn:ISBN:')
            }
          end

          def marc2dc_identifier_020_9(xml)
            # "urn:ISBN:"[MARC 020 9_ $a]
            each_field('0209_', 'a') { |f|
              xml['dc'].identifier('xsi:type' => 'dcterms:URI').text element(f, prefix: 'urn:ISBN:')
            }
          end

          def marc2dc_identifier_022(xml)
            # "urn:ISSN:"[MARC 022 __ $a]
            each_field('022__', 'a') { |f|
              xml['dc'].identifier('xsi:type' => 'dcterms:URI').text element(f, prefix: 'urn:ISSN:')
            }
          end

          def marc2dc_identifier_024_2(xml)
            # "urn:ISMN:"[MARC 024 2_ $a]
            each_field('0242_', 'a') { |f|
              xml['dc'].identifier('xsi:type' => 'dcterms:URI').text element(f, prefix: 'urn:ISMN:')
            }
          end

          def marc2dc_identifier_024_3(xml)
            # "urn:EAN:"[MARC 024 3_ $a]
            each_field('0243_', 'a') { |f|
              xml['dc'].identifier('xsi:type' => 'dcterms:URI').text element(f, prefix: 'urn:EAN:')
            }
          end

          def marc2dc_identifier_690(xml)
            # [MARC 690 02 $0]
            # all_tags('69002', '0a') { |t|
            #   if t._0 =~ /^\(ODIS-(PS|ORG)\)(\d)+$/
            #     xml['dc'].identifier('xsi:type' => 'dcterms:URI').text odis_link($1, $2, CGI::escape(t._a))
            #   else
            #     xml['dc'].identifier t._a
            #   end
            # }
            # ALMA: 690 02 ax0 => 650 _7 ax6 $2 == 'KADOC'
            all_tags('650_7', '6a') { |t|
              next unless t._2 == 'KADOC'
              if t._6 =~ /^\(ODIS-(PS|ORG)\)(\d)+$/
                xml['dc'].identifier('xsi:type' => 'dcterms:URI').text odis_link($1, $2, CGI::escape(t._a))
              else
                xml['dc'].identifier t._a
              end
            }
          end

          def marc2dc_identifier_856(xml)
            # [MARC 856 _2 $u]
            all_tags('856_2', 'uy') { |t|
              xml['dc'].identifier('xsi:type' => 'dcterms:URI').text element(t._u, CGI::escape(t._y), join: '#')
            }
          end

          def marc2dc_title(xml)
            # DC:TITLE
            marc2dc_title_245(xml)
            marc2dc_title_246(xml)
          end

          def marc2dc_title_245(xml)
            marc2dc_title_245_0(xml)
            marc2dc_title_245_1(xml)
          end

          def marc2dc_title_245_0(xml)
            # [MARC 245 0# $a] " " [MARC 245 0# $b] " [" [MARC 245 0# $h] "]"
            # all_tags('2450#', 'a b h') { |t|
            #   xml['dc'].title list_s(t._ab, opt_s(t._h))
            # }
            # ALMA: 245 ## Zh => 245 ## 6 [$h skipped, ': ' before $ skipped]
            all_tags('2450#', 'a b') { |t|
              xml['dc'].title element(t._ab, join: ' : ')
            }
          end

          def marc2dc_title_245_1(xml)
            # [MARC 245 1# $a] " " [MARC 245 1# $b] " [" [MARC 245 1# $h] "]"
            # all_tags('2451#', 'a b h') { |t|
            #   xml['dc'].title element(t._ab, opt_s(t._h), join: ' ')
            # }
            # ALMA: 245 ## Zh => 245 ## 6 [$h skipped, ': ' before $ skipped]
            all_tags('2451#', 'a b') { |t|
              xml['dc'].title element(t._ab, join: ' : ')
            }
          end

          def marc2dc_title_246(xml)
            # [MARC 246 11 $a] " : " [MARC 246 11 $b]
            all_tags('24611', 'a b') { |t|
              xml['dc'].title element(t._ab, join: ' : ')
            }
          end

          def marc2dc_ispartof(xml)
            # DCTERMS:ISPARTOF
            marc2dc_ispartof_243(xml)
            marc2dc_ispartof_440(xml)
            marc2dc_ispartof_lkr(xml)
            marc2dc_ispartof_773(xml)
          end

          def marc2dc_ispartof_243(xml)
            # [MARC 243 1# $a]
            # each_field('2431#', 'a') { |f| xml['dcterms'].isPartOf f }
            # ALMA: 243 ## a => 830 ## a
            each_field('8301#', 'a') { |f| xml['dcterms'].isPartOf f }
          end

          def marc2dc_ispartof_440(xml)
            # [MARC 440 _# $a] " : " [MARC 440 _# $b] " , " [MARC 440 _# $v]
            # all_tags('440_#', 'a b v') { |t|
            #   xml['dcterms'].isPartOf element({parts: t._ab, join: ' : '}, t._v, join: ' , ')
            # }
            # ALMA: 440 _# ab => 490 1_ a [$b replaced with ' : ']
            all_tags('4901_', 'a v') { |t|
              xml['dcterms'].isPartOf element(t._a, t._v, join: ' , ')
            }
          end

          def marc2dc_ispartof_lkr(xml)
            # [MARC LKR $n]
            each_field('LKR', 'n') { |f| xml['dcterms'].isPartOf f }
          end

          def marc2dc_ispartof_773(xml)
            # [MARC 773 0_ $a] " (" [MARC 773 0_ $g*]")"
            all_tags('7730_', 'a') { |t|
              xml['dcterms'].isPartOf element(t._a, opt_r(repeat(t.a_g)), join: ' ')
            }
          end

          def marc2dc_alternative(xml)
            # DCTERMS:ALTERNATIVE
            marc2dc_alternative_130(xml)
            marc2dc_alternative_240(xml)
            marc2dc_alternative_242(xml)
            marc2dc_alternative_246(xml)
            marc2dc_alternative_210(xml)
          end

          def marc2dc_alternative_130(xml)
            marc2dc_alternative_130_a(xml)
            marc2dc_alternative_130_l(xml)
          end

          def marc2dc_alternative_130_a(xml)
            # [MARC 130 #_ $a] ", " [MARC 130 #_ $f] ", " [MARC 130 #_ $g] ", "
            all_tags('130#_', 'a f g') { |t|
              xml['dcterms'].alternative element(t._afg, join: ', ', postfix: ', ')
            }
          end

          def marc2dc_alternative_130_l(xml)
            # [MARC 130 #_ $l] ", " [MARC 130 #_ $m] ", " [MARC 130 #_ $n] ", " [MARC 130 #_ $o] ", " [MARC 130 #_ $p] ", " [MARC 130 #_ $r] ", " [MARC 130 #_ $s]
            all_tags('130#_', 'l m n o p r s') { |t|
              xml['dcterms'].alternative element(t._lmnoprs, join: ', ')
            }
          end

          def marc2dc_alternative_240(xml)
            marc2dc_alternative_240_a(xml)
            marc2dc_alternative_240_l(xml)
          end

          def marc2dc_alternative_240_a(xml)
            # [MARC 240 1# $a] ", " [MARC 240 1# $f] ", " [MARC 240 1# $g] ", "
            all_tags('2401#', 'a f g') { |t|
              xml['dcterms'].alternative element(t._afg, join: ', ', postfix: ', ')
            }
          end

          def marc2dc_alternative_240_l(xml)
            # [MARC 240 1# $l] ", " [MARC 240 1# $m] ", " [MARC 240 1# $n] ", " [MARC 240 1# $o] ", " [MARC 240 1# $p] ", " [MARC 240 1# $r] ", " [MARC 240 1# $s]
            all_tags('2401#', 'l m n o p r s') { |t|
              xml['dcterms'].alternative element(t._lmnoprs, join: ', ')
            }
          end

          def marc2dc_alternative_242(xml)
            # [MARC 242 1# $a] ". " [MARC 242 1# $b]
            all_tags('2421#', 'a b') { |t|
              xml['dcterms'].alternative element(t._ab, join: '. ')
            }
          end

          def marc2dc_alternative_246(xml)
            marc2dc_alternative_246_13(xml)
            marc2dc_alternative_246_19(xml)
          end

          def marc2dc_alternative_246_13(xml)
            # [MARC 246 13 $a] ". " [MARC 246 13 $b]
            all_tags('24613', 'a b') { |t|
              xml['dcterms'].alternative element(t._ab, join: '. ')
            }
          end

          def marc2dc_alternative_246_19(xml)
            # [MARC 246 19 $a] ". " [MARC 246 19 $b]
            # all_tags('24619', 'a b') { |t|
            #   xml['dcterms'].alternative element(t._ab, join: '. ')
            # }
            # ALMA: 246 19 => 246 33
            all_tags('24633', 'a b') { |t|
              xml['dcterms'].alternative element(t._ab, join: '. ')
            }
          end

          def marc2dc_alternative_210(xml)
            # [MARC 210 10 $a]
            each_field('21010', 'a') { |f| xml['dcterms'].alternative f }
          end

          def marc2dc_creator(xml)
            # DC:CREATOR
            marc2dc_creator_100(xml)
            marc2dc_creator_700(xml)
            marc2dc_creator_710(xml)
            marc2dc_creator_711(xml)
          end

          def marc2dc_creator_100(xml)
            marc2dc_creator_100_0(xml)
            marc2dc_creator_100_1(xml)
          end

          def marc2dc_creator_100_0(xml)
            # [MARC 100 0_ $a] " " [MARC 100 0_ $b] " ("[MARC 100 0_ $c] ") " "("[MARC 100 0_ $d]") ("[MARC 100 0_ $g] "), " [MARC 100 0_ $4]" (" [MARC 100 0_ $9]")"
            all_tags('1000_', '4') { |t|
              next unless check_name(t, :creator)
              xml['dc'].creator element(list_s(t._ab, opt_r(t._c), opt_r(t._d), opt_r(t._g)),
                                        list_s(full_name(t), opt_r(t._9)),
                                        join: ', ')
            }
          end

          def marc2dc_creator_100_1(xml)
            # [MARC 100 1_ $a] " " [MARC 100 1_ $b] " ("[MARC 100 1_ $c] ") " "("[MARC 100 1_ $d]") ("[MARC 100 1_ $g]"), " [MARC 100 1_ $4]" ("[MARC 100 1_ $e]") (" [MARC 100 1_ $9]")"
            # all_tags('1001_', 'a b c d g e 9') { |t|
            #   next unless check_name(t, :creator)
            #   xml['dc'].creator element(list_s(t._ab, opt_r(t._c), opt_r(t._d), opt_r(t._g)),
            #                             list_s(full_name(t), opt_r(t._e), opt_r(t._9)),
            #                             join: ', ')
            # }

            # ALMA: 100 #_ 9 => 100 #_ 3
            all_tags('1001_', 'a b c d g e 3') { |t|
              next unless check_name(t, :creator)
              xml['dc'].creator element(list_s(t._ab, opt_r(t._c), opt_r(t._d), opt_r(t._g)),
                                        list_s(full_name(t), opt_r(t._e), opt_r(t._3)),
                                        join: ', ')
            }
          end

          def marc2dc_creator_700(xml)
            marc2dc_creator_700_0(xml)
            marc2dc_creator_700_1(xml)
          end

          def marc2dc_creator_700_0(xml)
            # [MARC 700 0_ $a] ", " [MARC 700 0_ $b] ", " [MARC 700 0_ $c] ", " [MARC 700 0_ $d] ", " [MARC 700 0_ $g] " (" [MARC 700 0_ $4] "), " [MARC 700 0_ $e]
            all_tags('7000_', 'g c d e') { |t|
              next unless check_name(t, :creator)
              xml['dc'].creator element(t._abcd,
                                        list_s(t._g, opt_r(full_name(t))),
                                        t._e,
                                        join: ', ')
            }
          end

          def marc2dc_creator_700_1(xml)
            # [MARC 700 1_ $a] ", " [MARC 700 1_ $b] ", " [MARC 700 1_ $c] ", " [MARC 700 1_ $d] ", " [MARC 700 1_ $g] " ( " [MARC 700 1_ $4] "), " [MARC 700 1_ $e]
            all_tags('7001_', 'a b c d g e') { |t|
              next unless check_name(t, :creator)
              xml['dc'].creator element(t._abcd,
                                        list_s(t._g, opt_r(full_name(t))),
                                        t._e,
                                        join: ', ')
            }
          end

          def marc2dc_creator_710(xml)
            marc2dc_creator_710_29(xml)
            marc2dc_creator_710_2_(xml)
          end

          def marc2dc_creator_710_29(xml)
            # [MARC 710 29 $a] ","  [MARC 710 29 $g]" (" [MARC 710 29 $4] "), " [MARC 710 29 $e]
            all_tags('71029', 'a g e') { |t|
              next unless check_name(t, :creator)
              xml['dc'].creator element(t._a,
                                        list_s(t._g, opt_r(full_name(t))),
                                        t._e,
                                        join: ', ')
            }
          end

          def marc2dc_creator_710_2_(xml)
            # [MARC 710 2_ $a] " (" [MARC 710 2_ $g] "), " [MARC 710 2_ $4] " (" [MARC 710 2_ $9*] ") ("[MARC 710 2_ $e]")"
            all_tags('7102_', 'a g e') { |t|
              next unless check_name(t, :creator)
              xml['dc'].creator element(list_s(t._a, opt_r(t._g)),
                                        list_s(full_name(t), opt_r(repeat(t.a_9)), opt_r(t._e)),
                                        join: ', ')
            }
          end

          def marc2dc_creator_711(xml)
            # [MARC 711 2_ $a] ", "[MARC 711 2_ $n] ", " [MARC 711 2_ $c] ", " [MARC 711 2_ $d] " (" [MARC 711 2_ $g] ")"
            all_tags('7112_', 'a n c d g') { |t|
              next unless check_name(t, :creator)
              xml['dc'].creator element(t._ancd, join: ', ', postfix: opt_r(t._g, prefix: ' '))
            }
          end

          def marc2dc_subject(xml)
            # DC:SUBJECT
            marc2dc_subject_600(xml)
            marc2dc_subject_610(xml)
            marc2dc_subject_611(xml)
            marc2dc_subject_630(xml)
            marc2dc_subject_650_x0(xml)
            marc2dc_subject_650_x2(xml)
            marc2dc_subject_691(xml)
            marc2dc_subject_082(xml)
            marc2dc_subject_690(xml)
            marc2dc_subject_650__7(xml)
          end

          def marc2dc_subject_600(xml)
            # [MARC 600 #0 $a] " " [MARC 600 #0 $b] " " [MARC 600 #0 $c] " " [MARC 600 #0 $d] " " [MARC 600 #0 $g]
            all_tags('600#0', 'a b c d g') { |t|
              xml['dc'].subject('xsi:type' => 'http://purl.org/dc/terms/LCSH').text list_s(t._abcdg)
            }
          end

          def marc2dc_subject_610(xml)
            # [MARC 610 #0 $a] " " [MARC 610 #0 $c] " " [MARC 610 #0 $d] " " [MARC 610 #0 $g]
            all_tags('610#0', 'a c d g') { |t|
              xml['dc'].subject('xsi:type' => 'http://purl.org/dc/terms/LCSH').text list_s(t._acdg)
            }
          end

          def marc2dc_subject_611(xml)
            # [MARC 611 #0 $a] " " [MARC 611 #0 $c] " " [MARC 611 #0 $d] " " [MARC 611 #0 $g] " " [MARC 611 #0 $n]
            all_tags('611#0', 'a c d g n') { |t|
              xml['dc'].subject('xsi:type' => 'http://purl.org/dc/terms/LCSH').text list_s(t._acdgn)
            }
          end

          def marc2dc_subject_630(xml)
            # [MARC 630 #0 $a] " " [MARC 630 #0 $f] " " [MARC 630 #0 $g] " " [MARC 630 #0 $l] " " [MARC 630 #0 $m] " " [MARC 630 #0 $n] " " [MARC 630 #0 $o] " " [MARC 630 #0 $p] " " [MARC 630 #0 $r] " " [MARC 630 #0 $s]
            all_tags('630#0', 'a f g l m n o p r s') { |t|
              xml['dc'].subject('xsi:type' => 'http://purl.org/dc/terms/LCSH').text list_s(t._afglmnoprs)
            }
          end

          def marc2dc_subject_650_x0(xml)
            # [MARC 650 #0 $a] " " [MARC 650 #0 $x] " " [MARC 650 #0 $y] " " [MARC 650 #0 $z]
            all_tags('650#0', 'a x y z') { |t|
              xml['dc'].subject('xsi:type' => 'http://purl.org/dc/terms/LCSH').text list_s(t._axyz)
            }
          end

          def marc2dc_subject_650_x2(xml)
            # [MARC 650 #2 $a] " " [MARC 650 #2 $x]
            all_tags('650#2', 'a x') { |t|
              attributes = {'xsi:type' => 'http://purl.org/dc/terms/MESH'}
              xml['dc'].subject(attributes).text list_s(t._ax)
            }
          end

          def marc2dc_subject_691(xml)
            # [MARC 691 E1 $8] " " [ MARC 691 E1 $a]
            # all_tags('691E1', 'a8') { |t|
            #   attributes = {'xsi:type' => 'http://purl.org/dc/terms/UDC'}
            #   x = taalcode(t._9)
            #   attributes['xml:lang'] = x if x
            #   xml['dc'].subject(attributes).text list_s(t._ax)
            # }
            # ALMA: 691 E1 8a => 650 _7 ax $2 == 'UDC' $9 skipped
            all_tags('650_7', 'a x') { |t|
              next unless t._2 == 'UDC'
              attributes = {'xsi:type' => 'http://purl.org/dc/terms/UDC'}
              xml['dc'].subject(attributes).text list_s(t._x) # should be t._ax by spec, but seems idiotic
            }
          end

          def marc2dc_subject_082(xml)
            # [MARC 082 14 $a] " " [MARC 082 14 $x]
            # all_tags('08214', 'a x') { |t|
            #   xml['dc'].subject('xsi:type' => 'http://purl.org/dc/terms/DDC', 'xml:lang' => 'en').text list_s(t._ax)
            # }
            # ALMA: 082 14 ax2 => 650 _7 ax4 $2 = 'DDC abridged'
            all_tags('650_7', 'a x') { |t|
              next unless t._2 == 'DDC abridged'
              xml['dc'].subject('xsi:type' => 'http://purl.org/dc/terms/DDC', 'xml:lang' => 'en').text list_s(t._ax)
            }
          end

          def marc2dc_subject_690(xml)
            # [MARC 690 [xx]$a]
            # Set dedups the fields
            # Set.new(each_field('690##', 'a')) { |f| xml['dc'].subject f }
            # ALMA: 690 ## => 650 _7
            # Set.new(all_fields('650_7', 'a')).each { |f| xml['dc'].subject f }
            # rule disbled gives duplicates and needs to be redefined by KUL cataloguing staff
          end

          def marc2dc_subject_650__7(xml)
            # KADOC: ODIS-TW zoals ODIS-PS
            all_tags('650_7', '26a') { |t|
              next unless t._2 == 'KADOC' and t._6 =~ /^\(ODIS-(TW)\)(\d)+$/
              # xml['dc'].identifier('xsi:type' => 'dcterms:URI').text odis_link($1, $2, CGI::escape(t._a))
              xml['dc'].subject list_s(t._a, element($2, prefix: '[', postfix: ']'))
            }
          end

          def marc2dc_temporal(xml)
            # DC:TEMPORAL
            marc2dc_temporal_648(xml)
            marc2dc_temporal_362(xml)
            marc2dc_temporal_752(xml)
          end

          def marc2dc_temporal_648(xml)
            # [MARC 648 #0 $a] " " [MARC 648 #0 $x] " " [MARC 648 #0 $y] " " [MARC 648 #0 $z]
            all_tags('648#0', 'a x y z') { |t|
              xml['dc'].temporal('xsi:type' => 'http://purl.org/dc/terms/LCSH').text list_s(t._axyz)
            }
          end

          def marc2dc_temporal_362(xml)
            # [MARC 362 __ $a]
            # each_field('362__', 'a') { |f| xml['dc'].temporal f }
            # ALMA: 362 __ a => 362 0_ a
            each_field('3620_', 'a') { |f| xml['dc'].temporal f }
          end

          def marc2dc_temporal_752(xml)
            # [MARC 752 9_ $9]
            # each_field('7529_', '9') { |f| xml['dc'].temporal f }
            # ALMA: 752 9_ 9 => 953 __ a
            each_field('953__', 'a') { |f| xml['dc'].temporal f }

            # [MARC 752 _9 $a] " (" [MARC 752 _9 $9]")"
            # all_tags('752_9', 'a 9') { |t|
            #   xml['dc'].temporal list_s(t._a, opt_r(t._9))
            # }
            # ALMA: 752 _9 a9 => 953 __ bc
            all_tags('953__', 'b c') { |t|
              xml['dc'].temporal list_s(t._b, opt_r(t._c))
            }
          end

          def marc2dc_description(xml)
            # DC:DESCRIPTION

            x = element(
                # [MARC 047 __ $a] " (" [MARC 047 __ $9]")"
                # all_tags('047__', 'a 9').collect { |t|
                #   list_s(t._a, opt_r(t._9))
                # },
                # ALMA: 047 __ a9 => 947 __ ab
                all_tags('947__', 'a b').collect { |t|
                  list_s(t._a, opt_r(t._b))
                },
                # [MARC 598 __ $a]
                # all_fields('598__', 'a'),
                # ALMA: 598 __ a => 958 __ a
                all_fields('958__', 'a'),
                # [MARC 597 __ $a]
                # all_fields('597__', 'a'),
                # ALMA: 597 __ a => 957 __ a
                all_fields('957__', 'a'),
                # [MARC 500 __ $a]
                all_fields('500__', 'a'),
                # [MARC 520 2_ $a]
                all_fields('5202_', 'a'),
                # "Projectie: " [MARC 093 __ $a]
                # all_tags('093__', 'a').collect { |t| element(t._a, prefix: 'Projectie: ') },
                # ALMA: 093 ## a => 954 __ a
                all_tags('954__', 'a').collect { |t| element(t._a, prefix: 'Projectie: ') },
                # "Equidistance " [MARC 094 __ $a*]
                # all_tags('094__', 'a').collect { |t| element(t.a_a, prefix: 'Equidistance ', join: ';') },
                # ALMA: 094 ## a => 954 __ b
                all_tags('954__', 'b').collect { |t| element(t.a_b, prefix: 'Equidistance ', join: ';') },
                # [MARC 502 __ $a] ([MARC 502 __ $9])
                # all_tags('502__', 'a 9').collect { |t|
                #   list_s(t._a, opt_r(t._9))
                # },
                # ALMA: 502 __ 9 => 502 __ g
                all_tags('502__', 'a g').collect { |t|
                  list_s(t._a, opt_r(t._g))
                },
                # [MARC 529 __ $a] ", " [MARC 529 __ $b] " (" [MARC 529 __ $c] ")"
                # all_tags('529__', 'a b 9').collect { |t|
                #   element(t._ab,
                #           join: ', ',
                #           postfix: opt_r(t._9))
                # },
                # ALMA: 529 __ ab9 => 957 __ abc
                all_tags('957__', 'a b c').collect { |t|
                  element(t._ab,
                          join: ', ',
                          postfix: opt_r(t._c))
                },
                # [MARC 534 9_ $a]
                # all_fields('5349_', 'a'),
                # ALMA: 534 9_ a => 534 __ t
                all_fields('534__', 't'),
                # [MARC 534 _9 $a] "(oorspronkelijke uitgever)"
                # all_fields('534_9', 'a').collect { |f| element(f, postfix: '(oorspronkelijke uitgever)') },
                # ALMA: 534 _9 a => 534 __ c
                all_fields('534__', 'c').collect { |f| element(f, postfix: '(oorspronkelijke uitgever)') },
                # [MARC 545 __ $a]
                all_fields('545__', 'a'),
                # [MARC 562 __ $a]
                # all_fields('562__', 'a'),
                # ALMA: 562 __ a => 963 __ a
                all_fields('963__', 'a'),
                # [MARC 563 __ $a] " " [MARC 563 __ $9] " (" [MARC 563 __ $u] ")"
                # all_tags('563__', 'a 9 u').collect { |t|
                #   list_s(t._a9, opt_r(t._u))
                # },
                # ALMA: 563 __ a9u => 563 __ a3u
                all_tags('563__', 'a 3 u').collect { |t|
                  list_s(t._a3, opt_r(t._u))
                },
                # [MARC 586 __ $a]
                all_fields('586__', 'a'),
                # [MARC 711 2_ $a] ", " [MARC 711 2_ $n] ", " [MARC 711 2_ $c] ", " [MARC 711 2_ $d] " (" [MARC 711 2_ $g]")"
                all_tags('7112_', 'a n c d g').collect { |t|
                  element(t._ancd,
                          join: ', ',
                          postfix: opt_r(t._g))
                },
                # [MARC 585 __ $a]
                all_fields('585__', 'a'),
                join: "\n"
            )
            xml['dc'].description x unless x.empty?
          end

          def marc2dc_isversionof(xml)
            # DCTERMS:ISVERSIONOF

            # [MARC 250 __ $a] " (" [MARC 250 __ $b] ")"
            all_tags('250__', 'a b') { |t|
              xml['dcterms'].isVersionOf list_s(t._a, opt_r(t._b))
            }
          end

          def marc2dc_abstract(xml)
            # DC:ABSTRACT
            marc2dc_abstract_520_3__a(xml)
            marc2dc_abstract_520_39_a(xml)
            marc2dc_abstract_520_3__u(xml)
            marc2dc_abstract_520_39_u(xml)
          end

          def marc2dc_abstract_520_3__a(xml)
            # [MARC 520 3_ $a]
            each_field('5203_', 'a') { |f| xml['dc'].abstract f }
          end

          def marc2dc_abstract_520_39_a(xml)
            # [MARC 520 39 $t] ": " [MARC 520 39 $a]
            all_tags('52039', 'a t') { |t|
              attributes = {}
              attributes['xml:lang'] = taalcode(t._9) if t.subfield_array('9').size == 1
              xml['dc'].abstract(attributes).text element(t._ta, join: ': ')
            }
          end

          def marc2dc_abstract_520_3__u(xml)
            # [MARC 520 3_ $u]
            each_field('5203_', 'u') { |f| xml['dc'].abstract('xsi:type' => 'dcterms:URI').text element(f) }
          end

          def marc2dc_abstract_520_39_u(xml)
            # [MARC 520 39 $u]
            each_field('52039', 'u') { |f| xml['dc'].abstract('xsi:type' => 'dcterms:URI').text element(f) }
          end

          def marc2dc_tableofcontents(xml)
            # DCTERMS:TABLEOFCONTENTS
            marc2dc_tableofcontents_505_0_(xml)
            marc2dc_tableofcontents_505_09(xml)
            marc2dc_tableofcontents_505_2_(xml)
          end

          def marc2dc_tableofcontents_505_0_(xml)
            # [MARC 505 0_  $a] " "[MARC 505 0_ $t]" / " [MARC 505 0_ $r*] " ("[MARC 505 0_ $9*]")"
            # all_tags('5050_', 'a t r 9') { |t|
            #   xml['dcterms'].tableOfContents list_s(t._at,
            #                                       repeat(t.a_r, prefix: '/ '),
            #                                       opt_r(repeat(t.a_9)))
            # }
            # ALMA: 505 ## 9 => 505 ## g
            all_tags('5050_', 'a t r g') { |t|
              xml['dcterms'].tableOfContents list_s(t._at,
                                                    repeat(t.a_r, prefix: '/ '),
                                                    opt_r(repeat(t.a_g)))
            }
          end

          def marc2dc_tableofcontents_505_09(xml)
            # [MARC 505 09 $a*] "\n" [MARC 505 09 $9*] "\n" [MARC 505 09 $u*]
            # all_tags('50509', 'a u 9') { |t|
            #   xml['dcterms'].tableOfContents element(repeat(t.a_a),
            #                                          repeat(t.a_9),
            #                                          repeat(t.a_u),
            #                                          join: "\n")
            # }
            # ALMA: 505 ## 9 => 505 ## g
            all_tags('50509', 'a u g') { |t|
              xml['dcterms'].tableOfContents element(repeat(t.a_a),
                                                     repeat(t.a_g),
                                                     repeat(t.a_u),
                                                     join: "\n")
            }
          end

          def marc2dc_tableofcontents_505_2_(xml)
            # [MARC 505 2_  $a] " "[MARC 505 2_ $t]" / " [MARC 505 2_ $r*] " ("[MARC 505 2_ $9*]")"
            # all_tags('5052_', 'a t r 9') { |t|
            #   xml['dcterms'].tableOfContents list_s(t._at,
            #                                       repeat(t.a_r, prefix: '/ '),
            #                                       opt_r(repeat(t.a_9)))
            # }
            # ALMA: 505 ## 9 => 505 ## g
            all_tags('5052_', 'a t r g') { |t|
              xml['dcterms'].tableOfContents list_s(t._at,
                                                    repeat(t.a_r, prefix: '/ '),
                                                    opt_r(repeat(t.a_g)))
            }
          end

          def marc2dc_available(xml)
            # DCTERMS:AVAILABLE

            # [MARC 591 ## $9] ":" [MARC 591 ## $a] " (" [MARC 591 ## $b] ")"
            # all_tags('591##', 'a b 9') { |t|
            #   xml['dcterms'].available element(t._9a, join: ':', postfix: opt_r(t._b, prefix: ' '))
            # }
            # ALMA: 591 __ ab9 => 866 __ axz
            all_tags('866##', 'a x z') { |t|
              xml['dcterms'].available element(t._za, join: ':', postfix: opt_r(t._x, prefix: ' '))
            }
          end

          def marc2dc_haspart(xml)
            # DCTERMS:HASPART

            # [MARC LKR $m]
            each_field('LKR', 'm') { |f| xml['dcterms'].hasPart f }
          end

          def marc2dc_contributor(xml)
            # DC:CONTRIBUTOR
            marc2dc_contributor_100_0(xml)
            marc2dc_contributor_100_1(xml)
            marc2dc_contributor_700(xml)
            marc2dc_contributor_710_29(xml)
            marc2dc_contributor_710_2_(xml)
            marc2dc_contributor_711(xml)
          end

          def marc2dc_contributor_100_0(xml)
            # [MARC 100 0_ $a] " " [MARC 100 0_ $b] " ("[MARC 100 0_ $c] ") (" [MARC 100 0_ $d]") ("[MARC 100 0_ $g]"), " [MARC 100 0_ $4]" (" [MARC 100 0_ $9]")"
            all_tags('1000_', 'a b c d g 9') { |t|
              next unless check_name(t, :contributor)
              xml['dc'].contributor element(list_s(t._ab,
                                                   opt_r(t._c),
                                                   opt_r(t._d),
                                                   opt_r(t._g)),
                                            list_s(full_name(t),
                                                   opt_r(t._9)),
                                            join: ', ')
            }
          end

          def marc2dc_contributor_100_1(xml)
            # [MARC 100 1_ $a] " " [MARC 100 1_ $b] " ("[MARC 100 1_ $c] ") " "("[MARC 100 1_ $d]") ("[MARC 100 1_ $g]"), " [MARC 100 1_ $4]" ("[MARC 100 1_ $e]") (" [MARC 100 1_ $9]")"
            all_tags('1001_', 'a b c d g e 9') { |t|
              next unless check_name(t, :contributor)
              xml['dc'].contributor element(list_s(t._ab,
                                                   opt_r(t._c),
                                                   opt_r(t._d),
                                                   opt_r(t._g)),
                                            list_s(full_name(t),
                                                   opt_r(t._e),
                                                   opt_r(t._9)),
                                            join: ', ')
            }
          end

          def marc2dc_contributor_700(xml)
            # [MARC 700 0_ $a] ", " [MARC 700 0_ $b] ", " [MARC 700 0_ $c] ", " [MARC 700 0_ $d] ", " [MARC 700 0_ $g] " ( " [MARC 700 0_ $4] "), " [MARC 700 0_ $e]
            # [MARC 700 1_ $a] ", " [MARC 700 1_ $b] ", " [MARC 700 1_ $c] ", " [MARC 700 1_ $d] ", " [MARC 700 1_ $g] " ( " [MARC 700 1_ $4] "), " [MARC 700 1_ $e]
            (all_tags('7000_', 'a b c d g e') + all_tags('7001_', 'a b c d g e')).each { |t|
              next unless check_name(t, :contributor)
              xml['dc'].contributor element(t._abcd,
                                            list_s(t._g,
                                                   opt_r(full_name(t), fix: '( |)')),
                                            t._e,
                                            join: ', ')
            }
          end

          def marc2dc_contributor_710_29(xml)
            # [MARC 710 29 $a] ","  [MARC 710 29 $g]" (" [MARC 710 29 $4] "), " [MARC 710 29 $e]
            all_tags('71029', 'a g e') { |t|
              next unless check_name(t, :contributor)
              xml['dc'].contributor element(t._a,
                                            list_s(t._g,
                                                   opt_r(full_name(t))),
                                            t._e,
                                            join: ', ')
            }
          end

          def marc2dc_contributor_710_2_(xml)
            # [MARC 710 2_ $a] " (" [MARC 710 2_ $g] "), " [MARC 710 2_ $4] " (" [MARC 710 2_ $9] ") ("[MARC 710 2_ $e]")"
            all_tags('7102_', 'a g 9 e') { |t|
              next unless check_name(t, :contributor)
              xml['dc'].contributor element(list_s(t._a,
                                                   opt_r(t._g)),
                                            list_s(full_name(t),
                                                   opt_r(t._9),
                                                   opt_r(t._e)),
                                            join: ', ')
            }
          end

          def marc2dc_contributor_711(xml)
            # [MARC 711 2_ $a] ", "[MARC 711 2_ $n] ", " [MARC 711 2_ $c] ", " [MARC 711 2_ $d] " (" [MARC 711 2_ $g] ")"
            all_tags('7112_', 'a n c d g') { |t|
              next unless check_name(t, :contributor)
              xml['dc'].contributor element(t._anc,
                                            list_s(t._d,
                                                   opt_r(t._g)),
                                            join: ', ')
            }
          end

          def marc2dc_provenance(xml)
            # DCTERMS:PROVENANCE
            marc2dc_provenance_852(xml)
            marc2dc_provenance_651(xml)
          end

          def marc2dc_provenance_852(xml)
            # [MARC 852 __ $b] " " [MARC 852 __ $c]
            all_tags('852__', 'b c') { |t|
              xml['dcterms'].provenance list_s(t._b == t._c ? t._b : t._bc)
            }
          end

          def marc2dc_provenance_651(xml)
            # [MARC 561 ## $a] " " [MARC 561 ## $b] " " [MARC 561 ## $9]
            all_tags('561##', 'a b 9') { |t|
              xml['dcterms'].provenance list_s(t._ab9)
            }
          end

          def marc2dc_publisher(xml)
            # DC:PUBLISHER
            marc2dc_publisher_260___(xml)
            marc2dc_publisher_260__9(xml)
            marc2dc_publisher_700(xml)
            marc2dc_publisher_710(xml)
          end

          def marc2dc_publisher_260___(xml)
            # [MARC 260 __ $e] " " [MARC 260 __ $f] " " [MARC 260 __ $c] " " [MARC 260 __ $9] " uitgave: " [MARC 260 __ $g]
            # all_tags('260__', 'e f c 9 g') { |t|
            #   xml['dc'].publisher list_s(t._efc9,
            #                              element(t._g, prefix: 'uitgave: '))
            # }
            # ALMA: 260 _# 9 => 260 __ 3
            all_tags('260__', 'e f c 3 g') { |t|
              xml['dc'].publisher list_s(t._efc3,
                                         element(t._g, prefix: 'uitgave: '))
            }
          end

          def marc2dc_publisher_260__9(xml)
            # [MARC 260 _9 $c] " " [MARC 260 _9 $9*] " (druk: ) " [MARC 260 _9 $g]
            # all_tags('260_9', 'c 9 g') { |t|
            #   xml['dc'].publisher list_s(t._c,
            #                              repeat(t.a_9),
            #                              element(t._g, prefix: 'druk: '))
            # }
            # ALMA: 260 _# 9 => 260 __ 3
            all_tags('260_9', 'c 3 g') { |t|
              xml['dc'].publisher list_s(t._c,
                                         repeat(t.a_3),
                                         element(t._g, prefix: 'druk: '))
            }
          end

          def marc2dc_publisher_700(xml)
            # [MARC 700 0_ $a] ", " [MARC 700 0_ $b] ", " [MARC 700 0_ $c] ", " [MARC 700 0_ $d] ", " [MARC 700 0_ $g] " ( " [MARC 700 0_ $4] "), " [MARC 700 0_ $e] "(uitgever)"
            all_tags('7000_', 'a b c d e g 4') { |t|
              next unless name_type(t) == :publisher
              xml['dc'].publisher element(t._abcd,
                                          list_s(t._g,
                                                 opt_r(full_name(t), fix: '( |)')),
                                          t._e,
                                          join: ', ',
                                          postfix: '(uitgever)')
            }
          end

          def marc2dc_publisher_710(xml)
            # [MARC 710 29 $a] "  (" [MARC 710 29 $c] "), " [MARC 710 29 $9]  ","  [710 29 $g] "(drukker)"
            all_tags('71029', 'a c g 9 4') { |t|
              xml['dc'].publisher element(list_s(t._a,
                                                 opt_r(t._c)),
                                          t._9g,
                                          join: ', ',
                                          postfix: '(drukker)')
            }
          end

          def marc2dc_date(xml)
            # DC:DATE
            marc2dc_date_008(xml)
            marc2dc_date_130(xml)
            marc2dc_date_240(xml)
          end

          def marc2dc_date_008(xml)
            # [MARC 008 (07-10)] " - " [MARC 008 (11-14)]
            all_tags('008') { |t|
              a = t.datas[7..10].dup
              b = t.datas[11..14].dup
              # return if both parts contained 'uuuu'
              next if a.gsub!(/^uuuu$/, 'xxxx') && b.gsub!(/^uuuu$/, 'xxxx')
              xml['dc'].date element(a, b, join: ' - ')
            }
          end

          def marc2dc_date_130(xml)
            # "Datering origineel werk: " [MARC 130 #_ $f]
            all_tags('130#_', 'f') { |t|
              xml['dc'].date element(t._f, prefix: 'Datering origineel werk: ')
            }
          end

          def marc2dc_date_240(xml)
            # "Datering compositie: " [MARC 240 1# $f]
            all_tags('2401#', 'f') { |t|
              xml['dc'].date element(t._f, prefix: 'Datering compositie: ')
            }
          end

          def marc2dc_type(xml)
            # DC:TYPE
            marc2dc_type_655_x9_a(xml)
            marc2dc_type_655_9x_a(xml)
            marc2dc_type_655__4_z(xml)
            marc2dc_type_fmt(xml)
            marc2dc_type_655_94_z(xml)
            marc2dc_type_655_9__a(xml)
            marc2dc_type_088_9__a(xml)
            marc2dc_type_088____z(xml)
            marc2dc_type_088____a(xml)
            marc2dc_type_655__4_a(xml)
            marc2dc_type_655_94_a(xml)
            marc2dc_type_088____x(xml)
            marc2dc_type_655__4_x(xml)
            marc2dc_type_655_94_x(xml)
            marc2dc_type_088____y(xml)
            marc2dc_type_655__4_y(xml)
            marc2dc_type_655_94_y(xml)
            marc2dc_type_655__2(xml)
          end

          def marc2dc_type_655_x9_a(xml)
            # [MARC 655 #9 $a]
            # each_field('655#9', 'a') { |f| xml['dc'].type f }
            # ALMA: 655 _9 a => 955 __ a
            each_field('955__', 'a') { |f| xml['dc'].type f }
          end

          def marc2dc_type_655_9x_a(xml)
            # [MARC 655 9# $a]
            # each_field('6559#', 'a') { |f| xml['dc'].type f }
            # ALMA: 655 9_ a => 955 __ b
            # Zie marc2dc_type_655_9__a
          end

          def marc2dc_type_655__4_z(xml)
            # [MARC 655 _4 $z]
            # each_field('655_4', 'z') { |f| xml['dc'].type f }
            # ALMA: 655 _4 axyz => 653 _6 a [$xyz skipped]
          end

          def marc2dc_type_fmt(xml)
            # [MARC FMT]
            all_tags('FMT') { |t| xml['dc'].type fmt(t.datas) }
          end

          def marc2dc_type_655_94_z(xml)
            # [MARC 655 94 $z]
            # each_field('65594', 'z') { |f| xml['dc'].type f }
            # ALMA: 655 94 axyz => 653 _6 a [$xyz skipped]
          end

          def marc2dc_type_655_9__a(xml)
            # [MARC 655 9_ $a]
            # each_field('6559_', 'a') { |f| xml['dc'].type f }
            # ALMA: 655 9_ a => 955 __ b
            each_field('955__', 'b') { |f| xml['dc'].type f }
          end

          def marc2dc_type_088_9__a(xml)
            # [MARC 088 9_ $a]
            # each_field('0889_', 'a') { |f| xml['dc'].type f } if each_field('088__', 'axy').empty?
            # ALMA: 088 9_ a9 => 340 __ d3
            # ALMA: 088 __ axyz9 => 340 __ a3 [$xyz skipped]
            each_field('340__', 'd') { |f| xml['dc'].type f } if each_field('340__', 'a').empty?
          end

          def marc2dc_type_088____z(xml)
            # [MARC 088 __ $z]
            # each_field('088__', 'z') { |f| xml['dc'].type f }
            # ALMA: 088 __ axyz9 => 340 __ a3 [$xyz skipped]
          end

          def marc2dc_type_088____a(xml)
            # [MARC 088 __ $a]
            # each_field('088__', 'a') { |f| xml['dc'].type('xml:lang' => 'en').text f }
            # ALMA: 088 __ axyz9 => 340 __ a3 [$xyz skipped]
            each_field('340__', 'a') { |f| xml['dc'].type('xml:lang' => 'en').text f }
          end

          def marc2dc_type_655__4_a(xml)
            # [MARC 655 _4 $a]
            # each_field('655_4', 'a') { |f| xml['dc'].type('xml:lang' => 'en').text f }
            # ALMA: 655 _4 axyz => 653 _6 a [$xyz skipped]
            each_field('653_6', 'a') { |f| xml['dc'].type('xml:lang' => 'en').text f }
          end

          def marc2dc_type_655_94_a(xml)
            # [MARC 655 94 $a]
            # each_field('65594', 'a') { |f| xml['dc'].type('xml:lang' => 'en').text f }
            # ALMA: 655 94 axyz => 635 _6 a [$xyz skipped]
            # Case covered by marc2dc_type_655__4_a
          end

          def marc2dc_type_088____x(xml)
            # [MARC 088 __ $x]
            # each_field('088__', 'x') { |f| xml['dc'].type('xml:lang' => 'nl').text f }
            # ALMA: 088 __ axyz9 => 340 __ a3 [$xyz skipped]
          end

          def marc2dc_type_655__4_x(xml)
            # [MARC 655 _4 $x]
            # each_field('655_4', 'x') { |f| xml['dc'].type('xml:lang' => 'nl').text f }
            # ALMA: 655 _4 axyz => 653 _6 a [$xyz skipped]
          end

          def marc2dc_type_655_94_x(xml)
            # [MARC 655 94 $x]
            # each_field('65594', 'x') { |f| xml['dc'].type('xml:lang' => 'nl').text f }
            # ALMA: 655 94 axyz => 653 _6 a [$xyz skipped]
          end

          def marc2dc_type_088____y(xml)
            # [MARC 088 __ $y]
            # each_field('088__', 'y') { |f| xml['dc'].type('xml:lang' => 'fr').text f }
            # ALMA: 088 __ axyz9 => 340 __ a3 [$xyz skipped]
          end

          def marc2dc_type_655__4_y(xml)
            # [MARC 655 _4 $y]
            # each_field('655_4', 'y') { |f| xml['dc'].type('xml:lang' => 'fr').text f }
            # ALMA: 655 _4 axyz => 653 _6 a [$xyz skipped]
          end

          def marc2dc_type_655_94_y(xml)
            # [MARC 655 94 $y]
            # each_field('65594', 'y') { |f| xml['dc'].type('xml:lang' => 'fr').text f }
            # ALMA: 655 94 axyz => 653 _6 a [$xyz skipped]
          end

          def marc2dc_type_655__2(xml)
            # [MARC 655 #2 $a] " " [MARC 655 #2 $x*] " " [MARC 655 #2 $9]
            all_tags('655#2', 'a x 9') { |t|
              xml['dc'].type({'xsi:type' => 'http://purl.org/dc/terms/MESH'}).text list_s(t._a,
                                                                                          repeat(t.a_x),
                                                                                          t._9)
            }
          end

          def marc2dc_spatial(xml)
            # DCTERMS:SPATIAL
            marc2dc_spatial_752(xml)
            marc2dc_spatial_034_1(xml)
            marc2dc_spatial_034_3(xml)
            marc2dc_spatial_034_9(xml)
            marc2dc_spatial_507(xml)
            marc2dc_spatial_651__0(xml)
            marc2dc_spatial_651__2(xml)
          end

          def marc2dc_spatial_752(xml)
            # [MARC 752 __ $a]  " " [MARC 752 __ $c] " " [MARC 752 __ $d] " (" [MARC 752 __ $9] ")"
            # all_tags('752__', 'a c d 9') { |t|
            #   xml['dcterms'].spatial list_s(t._acd,
            #                                 opt_r(t._9))
            # }
            # ALMA: 752 __ acd9 => 952 acde
            all_tags('952__', 'a c d e') { |t|
              xml['dcterms'].spatial list_s(t._acd,
                                            opt_r(t._e))
            }
          end

          def marc2dc_spatial_034_1(xml)
            # "Schaal: " [MARC 034 1_ $a]
            each_field('0341_', 'a') { |f|
              xml['dcterms'].spatial element(f, prefix: 'Schaal: ')
            }
          end

          def marc2dc_spatial_034_3(xml)
            # "Schaal: " [MARC 034 3_ $a*]
            all_tags('0343_', 'a') { |t|
              xml['dcterms'].spatial repeat(t.a_a, prefix: 'Schaal: ')
            }
          end

          def marc2dc_spatial_034_9(xml)
            # [MARC 034 91 $d] " " [MARC 034 91 $e] " " [MARC 034 91 $f] " " [MARC 034 91 $g]
            all_tags('03491', 'd e f g') { |t| xml['dcterms'].spatial list_s(t._defg) }
          end

          def marc2dc_spatial_507(xml)
            # [MARC 507 __ $a]
            each_field('507__', 'a') { |f| xml['dcterms'].spatial f }
          end

          def marc2dc_spatial_651__0(xml)
            # [MARC 651 #0 $a] " " [MARC 651 #0 $x*] " " [MARC 651 #0 $y] " " [MARC 651 #0 $z]
            all_tags('651#0', 'a x y z') { |t|
              xml['dcterms'].spatial({'xsi:type' => 'http://purl.org/dc/terms/LCSH'}).text list_s(t._a,
                                                                                                  repeat(t.a_x),
                                                                                                  t._yz)
            }
          end

          def marc2dc_spatial_651__2(xml)
            # [MARC 651 #2 $a] " " [MARC 651 #2 $x*]
            all_tags('651#2', 'a x') { |t|
              xml['dcterms'].spatial({'xsi:type' => 'http://purl.org/dc/terms/LCSH'}).text list_s(t._a,
                                                                                                  repeat(t.a_x))
            }
          end

          def marc2dc_extent(xml)
            # DCTERMS:EXTENT
            marc2dc_extent_300__(xml)
            marc2dc_extent_300_9(xml)
            marc2dc_extent_306(xml)
            marc2dc_extent_309(xml)
            marc2dc_extent_339(xml)
          end

          def marc2dc_extent_300__(xml)
            # [MARC 300 __ $a*] " " [MARC 300 __ $b] " " [MARC 300__  $c*] " " [MARC 300 __ $e] " (" [MARC 300 __ $9] ")"
            # all_tags('300__', 'a b c e 9') { |t|
            #   xml['dcterms'].extent list_s(repeat(t.a_a),
            #                              t._b,
            #                              repeat(t.a_c),
            #                              t._e,
            #                              opt_r(t._9))
            # }
            # ALMA: 300 __ 9 => 300 __ g
            all_tags('300__', 'a b c e g') { |t|
              xml['dcterms'].extent list_s(repeat(t.a_a),
                                           t._b,
                                           repeat(t.a_c),
                                           t._e,
                                           opt_r(t._g))
            }
          end

          def marc2dc_extent_300_9(xml)
            # [MARC 300 9_ $a] " " [MARC 300 9_ $b] " " [MARC 300 9_ $c*] " " [MARC 300 9_ $e] " (" [MARC 300 9_ $9]")"
            # all_tags('3009_', 'a b c e 9') { |t|
            #   xml['dcterms'].extent list_s(t._ab,
            #                              repeat(t.a_c),
            #                              t._e,
            #                              opt_r(t._9))
            # }
            # ALMA: 300 9_ ac => 300 9_ ac
            # ALMA: 300 9_ b9 => 340 __ oc
            # This change is not compatible with DC converter (only 1 tag per DC element). 2 DC elements generated instead.
            all_tags('3009_', 'a c') { |t|
              xml['dcterms'].extent list_s(t._a, repeat(t.a_c))
            }
            all_tags('340__', 'o c') { |t|
              xml['dcterms'].extent list_s(t._o, opt_r(t._c))
            }
          end

          def marc2dc_extent_306(xml)
            # [MARC 306 __  $a*]
            all_tags('306__', 'a') { |t| xml['dcterms'].extent repeat(t.a_a.collect { |y| y.scan(/(\d\d)(\d\d)(\d\d)/).join(':') }) }
          end

          def marc2dc_extent_309(xml)
            # [MARC 309 __ $a]
            # each_field('309__', 'a') { |f| xml['dcterms'].extent f }
            # ALMA: 309 __ a => 306 __ a
            # covered by marc2dc_extent_306
          end

          def marc2dc_extent_339(xml)
            # [MARC 339 __ $a*]
            # all_tags('339__', 'a') { |t| xml['dcterms'].extent repeat(t.a_a) }
            # ALMA: 339 __ a => 340 __ d
            all_tags('340__', 'd') { |t| xml['dcterms'].extent repeat(t.a_d) }
          end

          def marc2dc_accrualperiodicity(xml)
            # DCTERMS:ACCRUALPERIODICITY

            # [MARC 310 __ $a] " (" [MARC 310 __ $b] ")"
            all_tags('310__', 'a b') { |t|
              xml['dcterms'].accrualPeriodicity list_s(t._a,
                                                       opt_r(t._b))
            }
          end

          def marc2dc_format(xml)
            # DC:FORMAT

            # [MARC 340 __ $a*]
            all_tags('340__', 'a') { |t|
              xml['dc'].format repeat(t.a_a)
            }
          end

          def marc2dc_medium(xml)
            # DCTERMS:MEDIUM
            marc2dc_medium_319__(xml)
            marc2dc_medium_319_9(xml)
            marc2dc_medium_399(xml)
          end

          def marc2dc_medium_319__(xml)
            # [MARC 319 __ $a]
            # each_field('319__', 'a') { |f| xml['dcterms'].medium f }
            # ALMA: 319 __ a => 340 __ e
            each_field('340__', 'e') { |f| xml['dcterms'].medium f }
          end

          def marc2dc_medium_319_9(xml)
            # [MARC 319 9_ $a] " (" [MARC 319 9_ $9] ")"
            # all_tags('3199_', 'a 9') { |t|
            #   xml['dcterms'].medium list_s(t._a,
            #                              opt_r(t._9))
            # }
            # ALMA: 319 9_ a => 340 __ e
            # covered by marc2dc_medium_319__
          end

          def marc2dc_medium_399(xml)
            # [MARC 399 __ $a]  " " [MARC 399 __ $b] " (" [MARC 399 __ $9] ")"
            # all_tags('399__', 'a b 9') { |t|
            #   xml['dcterms'].medium list_s(t._ab,
            #                              opt_r(t._9))
            # }
            # ALMA: 399 __ ab9 => 950 __ abc
            all_tags('950__', 'a b c') { |t|
              xml['dcterms'].medium list_s(t._ab,
                                           opt_r(t._c))
            }
          end

          def marc2dc_relation(xml)
            # DC:RELATION

            # [MARC 580 __ $a]
            each_field('580__', 'a') { |e| xml['dc'].relation e }
          end

          def marc2dc_replaces(xml)
            # DCTERMS:REPLACES

            # [MARC 247 1# $a] " : " [MARC 247 1# $b] " (" [MARC 247 1# $9] ")"
            # all_tags('2471#', 'a b 9') { |t|
            #   xml['dcterms'].replaces list_s(element(t._a, t._b, join: ' : '), opt_r(t._9))
            # }
            # ALMA: 247 10 9Z => 247 10 g6
            all_tags('2471#', 'a b g') { |t|
              xml['dcterms'].replaces list_s(element(t._a, t._b, join: ' : '), opt_r(t._g))
            }
          end

          def marc2dc_hasversion(xml)
            # DCTERMS:HASVERSION

            # [MARC 534 __ $a]
            # each_field('534__', 'a') { |f| xml['dcterms'].hasVersion f }
            # ALMA: 534 __ a => 534 __ b
            each_field('534__', 'b') { |f| xml['dcterms'].hasVersion f }
          end

          def marc2dc_source(xml)
            # DC:SOURCE
            marc2dc_source_852___(xml)
            marc2dc_source_856(xml)
          end

          def marc2dc_source_852___(xml)
            # [MARC 852 __ $b] " " [MARC 852 __ $c] " " [MARC 852 __ $k] " " [MARC 852 __ $h] " " [MARC 852 __ $9] " " [MARC 852 __ $l] " " [MARC 852 __ $m]
            # all_tags('852__', 'b c k h 9 l m') { |t|
            #   xml['dc'].source list_s(t._bckh9lm)
            # }
            # ALMA: 852 __ 9 => 852 __ i
            all_tags('852__', 'b c k h i l m') { |t|
              xml['dc'].source list_s(t._bckhilm)
            }
          end

          def marc2dc_source_856(xml)
            marc2dc_source_856__1(xml)
            marc2dc_source_856__2(xml)
            marc2dc_source_856_4(xml)
          end

          def marc2dc_source_856__1(xml)
            # [MARC 856 _1 $u]
            all_tags('856_1', 'uy') { |t|
              xml['dc'].source('xsi:type' => 'dcterms:URI').text element(t._u,
                                                                         repeat(t.a_y.collect { |y| CGI::escape(y) }),
                                                                         join: '#')
            }
          end

          def marc2dc_source_856__2(xml)
            # [MARC 856 _2 $u]
            all_tags('856_2', 'uy') { |t|
              xml['dc'].source('xsi:type' => 'dcterms:URI').text element(t._u,
                                                                         repeat(t.a_y.collect { |y| CGI::escape(y) }),
                                                                         join: '#')
            }
          end

          def marc2dc_source_856_4(xml)
            # [MARC 856 40 $u]
            all_tags('85640', 'u') { |t|
              xml['dc'].source('xsi:type' => 'dcterms:URI').text element(t._u)
            }
          end

          def marc2dc_language(xml)
            # DC:LANGUAGE
            marc2dc_language_041_9(xml)
            marc2dc_language_008(xml)
            marc2dc_language_130(xml)
            marc2dc_language_240(xml)
            marc2dc_language_546(xml)
          end

          def marc2dc_language_041_9(xml)
            marc2dc_language_041_9_(xml)
            marc2dc_language_041__9(xml)
          end

          def marc2dc_language_041_9_(xml)
            marc2dc_language_041_9___a(xml)
            marc2dc_language_041_9__d(xml)
            marc2dc_language_041_9__e(xml)
            marc2dc_language_041_9__f(xml)
            marc2dc_language_041_9__h(xml)
            marc2dc_language_014_9__9(xml)
          end

          def marc2dc_language_041_9___a(xml)
            # [MARC 041 9_ $a*]
            all_tags('0419_', 'a') { |t|
              xml['dc'].language repeat(t.a_a.collect { |y| taalcode(y) })
            }
          end

          def marc2dc_language_041_9__d(xml)
            # [MARC 041 9_ $d*]
            all_tags('0419_', 'd') { |t|
              xml['dc'].language repeat(t.a_d.collect { |y| taalcode(y) })
            }
          end

          def marc2dc_language_041_9__e(xml)
            # [MARC 041 9_ $e*]
            all_tags('0419_', 'e') { |t|
              xml['dc'].language repeat(t.a_e.collect { |y| taalcode(y) })
            }
          end

          def marc2dc_language_041_9__f(xml)
            # [MARC 041 9_ $f*]
            all_tags('0419_', 'f') { |t|
              xml['dc'].language repeat(t.a_f.collect { |y| taalcode(y) })
            }
          end

          def marc2dc_language_041_9__h(xml)
            # [MARC 041 9_ $h*]
            all_tags('0419_', 'h') { |t|
              xml['dc'].language repeat(t.a_h.collect { |y| taalcode(y) })
            }
          end

          def marc2dc_language_014_9__9(xml)
            # [MARC 041 9_ $9*]
            # all_tags('0419_', '9') { |t|
            #   xml['dc'].language repeat(t.a_9.collect { |y| taalcode(y) })
            # }
            # ALMA: 041 9# 9 => 041 __ k
            all_tags('041__', 'k') { |t|
              xml['dc'].language repeat(t.a_k.collect { |y| taalcode(y) })
            }
          end

          def marc2dc_language_041__9(xml)
            marc2dc_language_041__9_a(xml)
            marc2dc_language_041__9_h(xml)
            marc2dc_language_041__9_9(xml)
          end

          def marc2dc_language_041__9_a(xml)
            # "Gedubde taal: " [MARC 041 _9 $a*]
            all_tags('041_9', 'a') { |t|
              xml['dc'].language repeat(t.a_a.collect { |y| taalcode(y) }, prefix: 'Gedubde taal:')
            }
          end

          def marc2dc_language_041__9_h(xml)
            # [MARC 041 _9 $h*]
            all_tags('041_9', 'h') { |t|
              xml['dc'].language repeat(t.a_h.collect { |y| taalcode(y) })
            }
          end

          def marc2dc_language_041__9_9(xml)
            # "Ondertitels: " [MARC 041 _9 $9*]
            # all_tags('041_9', '9') { |t|
            #   xml['dc'].language element(t.a_9.collect { |y| taalcode(y) }, prefix: 'Ondertitels:')
            # }
            # ALMA: 041 #9 9 => 041 __ j
            all_tags('041__', 'j') { |t|
              xml['dc'].language element(t.a_j.collect { |y| taalcode(y) }, prefix: 'Ondertitels:')
            }
          end

          def marc2dc_language_008(xml)
            # [MARC 008 (35-37)]
            all_tags('008') { |t|
              xml['dc'].language taalcode(t.datas[35..37])
            } if all_tags('041').empty?
          end

          def marc2dc_language_130(xml)
            # [MARC 130 #_ $l]
            each_field('130#_', 'l') { |f| xml['dc'].language f }
          end

          def marc2dc_language_240(xml)
            # [MARC 240 #_ $l]
            each_field('240#_', 'l') { |f| xml['dc'].language f }
          end

          def marc2dc_language_546(xml)
            # [MARC 546 __ $a]
            each_field('546__', 'a') { |f| xml['dc'].language f }

            # [MARC 546 9_ $a]
            # ALMA: 546 9_ a => 546 __ a
            # each_field('5469_', 'a') { |f| xml['dc'].language f }

            # [MARC 546 _9 $a]
            # ALMA: 546 _9 a => 546 __ a
            # each_field('546_9', 'a') { |f| xml['dc'].language f }
          end

          def marc2dc_rightsholder(xml)
            # DCTERMS:RIGHTSHOLDER
            marc2dc_rightsholder_700(xml)
            marc2dc_rightsholder_710(xml)
          end

          def marc2dc_rightsholder_700(xml)
            # [MARC 700 0_ $a] ", " [MARC 700 0_ $b] ", " [MARC 700 0_ $c] ", " [MARC 700 0_ $d] ", " [MARC 700 0_ $g] ", " [MARC 700 0_ $e] (als $4 cph)
            all_tags('7000_', '4') { |t|
              next unless check_name(t, :rightsholder)
              xml['dcterms'].rightsholder element(t._abcdge, join: ', ')
            }
          end

          def marc2dc_rightsholder_710(xml)
            # [MARC 710 2_ $a] " (" [MARC 710 2_ $g] "), (" [MARC 710 2_ $9] ") ("[MARC 710 2_ $e]")" (als $4 cph)
            all_tags('7102_', '4') { |t|
              next unless check_name(t, :rightsholder)
              xml['dcterms'].rightsholder element(list_s(t._a,
                                                         opt_r(t._g)),
                                                  list_s(opt_r(t._9),
                                                         opt_r(t._e)),
                                                  join: ', ')
            }
          end

          def marc2dc_references(xml)
            # DCTERMS:REFERENCES

            # [MARC 581 __ $a]
            each_field('581__', 'a') { |f| xml['dcterms'].references f }
          end

          def marc2dc_isreferencedby(xml)
            # DCTERMS:ISREFERENCEDBY
            marc2dc_isreferencedby_510_0(xml)
            marc2dc_isreferencedby_510_3(xml)
            marc2dc_isreferencedby_510_4(xml)
          end

          def marc2dc_isreferencedby_510_0(xml)
            # [MARC 510 0_ $a] ", " [MARC 510 0_ $c]
            all_tags('5100_', 'a c') { |t|
              xml['dcterms'].isReferencedBy element(t._ac, join: ', ')
            }
          end

          def marc2dc_isreferencedby_510_3(xml)
            # [MARC 510 3_ $a] ", " [MARC 510 3_ $c]
            all_tags('5103_', 'a c') { |t|
              xml['dcterms'].isReferencedBy element(t._ac, join: ', ')
            }
          end

          def marc2dc_isreferencedby_510_4(xml)
            # [MARC 510 4_ $a] ", " [MARC 510 4_ $c]
            all_tags('5104_', 'a c') { |t|
              xml['dcterms'].isReferencedBy element(t._ac, join: ', ')
            }
          end

          def marc2dc_coverage(xml)
            # KADOC: ODIS-GEO zoals ODIS-PS
            all_tags('650_7', '26a') { |t|
              next unless t._2 == 'KADOC' and t._6 =~ /^\(ODIS-(GEO)\)(\d)+$/
              # xml['dc'].identifier('xsi:type' => 'dcterms:URI').text odis_link($1, $2, CGI::escape(t._a))
              xml['dc'].coverage list_s(t._a, element($2, prefix: '[', postfix: ']'))
            }

          end

          protected

          def check_name(data, b)
            name_type(data) == b
          end

          def name_type(data)
            #noinspection RubyResolve
            code = data._4.to_sym
            if DOLLAR4TABLE[data.tag].has_key? code
              return DOLLAR4TABLE[data.tag][code][1]
            end
            :contributor
          end

          def full_name(data)
            #noinspection RubyResolve
            code = data._4.to_sym
            return '' unless DOLLAR4TABLE[data.tag].has_key? code
            DOLLAR4TABLE[data.tag][code][0]
          end

          def taalcode(code)
            TAALCODES[code.to_sym]
          end

          def bibnaam(code)
            BIBCODES[code] || ''
          end

          def fmt(code)
            FMT[code.to_sym] || ''
          end

          def lookup(table, key, constraints = {})
            table.select { |value| constraints.map { |k, v| value[k] == v }.all? }.map { |v| v[key] }
          end

          #noinspection RubyStringKeysInHashInspection
          DOLLAR4TABLE = {
              '700' => {
                  apb: ['approbation, approbatie, approbation', :contributor],
                  apr: ['preface', nil],
                  arc: ['architect', :contributor],
                  arr: ['arranger', :contributor],
                  art: ['artist', :creator],
                  aui: ['author of introduction', :contributor],
                  aut: ['author', :creator],
                  bbl: ['bibliography', :contributor],
                  bdd: ['binder', :contributor],
                  bsl: ['bookseller', :contributor],
                  ccp: ['concept', :contributor],
                  chr: ['choreographer', :contributor],
                  clb: ['collaborator', :contributor],
                  cmm: ['commentator (rare books only)', :contributor],
                  cmp: ['composer', :contributor],
                  cnd: ['conductor', :contributor],
                  cns: ['censor, censeur', :contributor],
                  cod: ['co-ordination', :contributor],
                  cof: ['collection from', :contributor],
                  coi: ['compiler index', :contributor],
                  com: ['compiler', :contributor],
                  con: ['consultant', :contributor],
                  cov: ['cover designer', :contributor],
                  cph: ['copyright holder', :rightsholder],
                  cre: ['creator', :creator],
                  csp: ['project manager', :contributor],
                  ctb: ['contributor', :contributor],
                  ctg: ['cartographer', :creator],
                  cur: ['curator', :contributor],
                  dfr: ['defender (rare books only)', :contributor],
                  dgg: ['degree grantor', :contributor],
                  dir: ['director', :creator],
                  dnc: ['dancer', :contributor],
                  dpc: ['depicted', :contributor],
                  dsr: ['designer', :contributor],
                  dte: ['dedicatee', :contributor],
                  dub: ['dubious author', :creator],
                  eda: ['editor assistant', :contributor],
                  edc: ['editor in chief', :creator],
                  ede: ['final editing', :creator],
                  edt: ['editor', :creator],
                  egr: ['engraver', :contributor],
                  eim: ['editor of image', :contributor],
                  eow: ['editor original work', :contributor],
                  etc: ['etcher', :contributor],
                  etr: ['etcher', :contributor],
                  eul: ['eulogist, drempeldichter, panégyriste', :contributor],
                  hnr: ['honoree', :contributor],
                  ihd: ['expert trainee post (inhoudsdeskundige stageplaats)', :contributor],
                  ill: ['illustrator', :contributor],
                  ilu: ['illuminator', :contributor],
                  itr: ['instrumentalist', :contributor],
                  ive: ['interviewee', :contributor],
                  ivr: ['interviewer', :contributor],
                  lbt: ['librettist', :contributor],
                  ltg: ['lithographer', :contributor],
                  lyr: ['lyricist', :contributor],
                  mus: ['musician', :contributor],
                  nrt: ['narrator, reader', :contributor],
                  ogz: ['started by', :creator],
                  oqz: ['continued by', :creator],
                  orc: ['orchestrator', :contributor],
                  orm: ['organizer of meeting', :contributor],
                  oth: ['other', :contributor],
                  pat: ['patron, opdrachtgever, maître d\'oeuvre', :contributor],
                  pht: ['photographer', :creator],
                  prf: ['performer', :contributor],
                  pro: ['producer', :contributor],
                  prt: ['printer', :publisher],
                  pub: ['publication about', :subject],
                  rbr: ['rubricator', :contributor],
                  rea: ['realization', :contributor],
                  reb: ['revised by', :contributor],
                  rev: ['reviewer', :contributor],
                  rpt: ['reporter', :contributor],
                  rpy: ['responsible party', :contributor],
                  sad: ['scientific advice', :contributor],
                  sce: ['scenarist', :contributor],
                  sco: ['scientific co-operator', :contributor],
                  scr: ['scribe', :contributor],
                  sng: ['singer', :contributor],
                  spn: ['sponsor', :contributor],
                  tec: ['technical direction', :contributor],
                  thc: ['thesis co-advisor(s)', :contributor],
                  thj: ['member of the jury', :contributor],
                  ths: ['thesis advisor', :contributor],
                  trc: ['transcriber', :contributor],
                  trl: ['translator', :contributor],
                  udr: ['under direction of', :contributor],
                  voc: ['vocalist', :contributor],
              },
              '710' => {
                  adq: ['readapted by', :contributor],
                  add: ['addressee, bestemmeling', :contributor],
                  aow: ['author original work, auteur oorspronkelijk werk, auteur ouvrage original', :contributor],
                  apr: ['preface', :/],
                  arc: ['architect', :contributor],
                  art: ['artist', :creator],
                  aut: ['author', :creator],
                  bbl: ['bibliography', :contributor],
                  bdd: ['binder', :contributor],
                  bsl: ['bookseller', :contributor],
                  ccp: ['Conceptor', :contributor],
                  clb: ['collaborator', :contributor],
                  cod: ['co-ordination', :contributor],
                  cof: ['collection from', :contributor],
                  coi: ['compiler index', :contributor],
                  com: ['compiler', :contributor],
                  con: ['consultant', :contributor],
                  cov: ['cover designer', :contributor],
                  cph: ['copyright holder', :rightsholder],
                  cre: ['creator', :creator],
                  csp: ['project manager', :contributor],
                  ctb: ['contributor', :contributor],
                  ctg: ['cartographer', :contributor],
                  cur: ['curator', :contributor],
                  dgg: ['degree grantor', :contributor],
                  dnc: ['dancer', :contributor],
                  dsr: ['designer', :contributor],
                  dte: ['dedicatee', :contributor],
                  eda: ['editor assistant', :contributor],
                  edc: ['editor in chief', :creator],
                  ede: ['final editing', :creator],
                  edt: ['editor', :creator],
                  egr: ['engraver', :contributor],
                  eim: ['editor of image', :contributor],
                  eow: ['editor original work', :contributor],
                  etc: ['etcher', :contributor],
                  eul: ['eulogist, drempeldichter, panégyriste', :contributor],
                  hnr: ['honoree', :contributor],
                  itr: ['instrumentalist', :contributor],
                  ltg: ['lithographer', :contributor],
                  mus: ['musician', :contributor],
                  ogz: ['started by', :creator],
                  oqz: ['continued by', :creator],
                  ori: ['org. institute (rare books/mss only)', :contributor],
                  orm: ['organizer of meeting', :contributor],
                  oth: ['other', :contributor],
                  pat: ['patron', :contributor],
                  pht: ['photographer', :creator],
                  prf: ['performer', :contributor],
                  pro: ['producer', :contributor],
                  prt: ['printer', :publisher],
                  pub: ['publication about', :subject],
                  rea: ['realization', :contributor],
                  rpt: ['reporter', :contributor],
                  rpy: ['responsible party', :contributor],
                  sad: ['scientific advice', :contributor],
                  sco: ['scientific co-operator', :contributor],
                  scp: ['scriptorium', :contributor],
                  sng: ['singer', :contributor],
                  spn: ['sponsor', :contributor],
                  tec: ['technical direction', :contributor],
                  trc: ['transcriber', :contributor],
                  trl: ['translator', :contributor],
                  udr: ['under direction of', :contributor],
                  voc: ['vocalist', :contributor],
              },
              '711' => {
                  oth: ['other', :contributor],
              },
              '100' => {
                  arr: ['arranger', :contributor],
                  aut: ['author', :creator],
                  cmp: ['composer', :contributor],
                  com: ['compiler', :contributor],
                  cre: ['creator', :creator],
                  ctg: ['cartographer', :creator],
                  ill: ['illustrator', :contributor],
                  ivr: ['interviewer', :contributor],
                  lbt: ['librettist', :contributor],
                  lyr: ['lyricist', :contributor],
                  pht: ['photographer', :creator],
              }
          }

          TAALCODES = {
              afr: 'af',
              ara: 'ar',
              chi: 'zh',
              cze: 'cs',
              dan: 'da',
              dum: 'dum',
              dut: 'nl',
              est: 'et',
              eng: 'en',
              fin: 'fi',
              fre: 'fr',
              frm: 'frm',
              ger: 'de',
              grc: 'grc',
              gre: 'el',
              hun: 'hu',
              fry: 'fy',
              ita: 'it',
              jpn: 'ja',
              lat: 'la',
              lav: 'lv',
              liv: 'lt',
              ltz: 'lb',
              mlt: 'mt',
              nor: 'no',
              pol: 'pl',
              por: 'pt',
              rus: 'ru',
              slo: 'sk',
              slv: 'sl',
              spa: 'es',
              swe: 'sv',
              tur: 'tr',
              ukr: 'uk',
              syc: '',
              syr: '',
              heb: '',
              cop: '',
          }

          #noinspection RubyStringKeysInHashInspection
          BIBCODES = {
              '01' => 'K.U.Leuven',
              '02' => 'KADOC',
              '03' => 'BB(Boerenbond)/KBC',
              '04' => 'HUB',
              '05' => 'ACV',
              '06' => 'LIBAR',
              '07' => 'SHARE',
              '10' => 'BPB',
              '11' => 'VLP',
              '12' => 'TIFA',
              '13' => 'LESSIUS',
              '14' => 'SERV',
              '15' => 'ACBE',
              '16' => 'SLUCB',
              '17' => 'SLUCG',
              '18' => 'HUB',
              '19' => 'KHBO',
              '20' => 'FINBI',
              '21' => 'BIOET',
              '22' => 'LUKAS',
              '23' => 'KHM',
              '24' => 'Fonds',
              '25' => 'RBINS',
              '26' => 'RMCA',
              '27' => 'NBB',
              '28' => 'Pasteurinstituut',
              '29' => 'Vesalius',
              '30' => 'Lemmensinstituut',
              '31' => 'KHLIM',
              '32' => 'KATHO',
              '33' => 'KAHO',
              '34' => 'HUB',
          }

          FMT = {
              BK: 'Books',
              SE: 'Continuing Resources',
              MU: 'Music',
              MP: 'Maps',
              VM: 'Visual Materials',
              AM: 'Audio Materials',
              CF: 'Computer Files',
              MX: 'Mixed Materials',
          }

        end

      end
    end
  end
end
