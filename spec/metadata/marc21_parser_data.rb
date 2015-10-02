def marc21_parser_testdata
  [
      {
          title: 'select statement with numeric tag',
          input: 'MARC 123',
          tree: {tag: '123', ind1: nil, ind2: nil, subfield: nil, condition: nil},
          transform: "record.select_fields('123##')"
      }, {
          title: 'select statement with LRK tag',
          input: 'MARC LKR',
          tree: {tag: 'LKR', ind1: nil, ind2: nil, subfield: nil, condition: nil},
          transform: "record.select_fields('LKR##')"
      }, {
          title: 'select statement with FMT tag',
          input: 'MARC FMT',
          tree: {tag: 'FMT', ind1: nil, ind2: nil, subfield: nil, condition: nil},
          transform: "record.select_fields('FMT##')"
      }, {
          title: 'select statement with bad magic text',
          input: 'foo',
          tree: :failure
      }, {
          title: 'select statement with bad tag',
          input: 'MARC 1',
          tree: :failure
      }, {
          title: 'select statement with bad indicator',
          input: 'MARC 123 *',
          tree: :failure
      }, {
          title: 'select statement with bad subfield',
          input: 'MARC 123 $_',
          tree: :failure
      }, {
          title: 'select statement with tag and one indicator',
          input: 'MARC 123 #',
          tree: {tag: '123', ind1: '#', ind2: nil, subfield: nil, condition: nil},
          transform: "record.select_fields('123##')"
      }, {
          title: 'select statement with tag and indicators',
          input: 'MARC 123 #_',
          tree: {tag: '123', ind1: '#', ind2: '_', subfield: nil, condition: nil},
          transform: "record.select_fields('123#_')"
      }, {
          title: 'select statement with tag and subfield',
          input: 'MARC 123 $a',
          tree: {tag: '123', ind1: nil, ind2: nil, subfield: {name: 'a'}, condition: nil},
          transform: "record.select_fields('123##a')"
      }, {
          title: 'select statement with tag, indicators and subfield',
          input: 'MARC 123 45 $6',
          tree: {tag: '123', ind1: '4', ind2: '5', subfield: {name: '6'}, condition: nil},
          transform: "record.select_fields('123456')"
      }, {
          title: 'select statement with subfield condition',
          input: 'MARC 123 [f.match(\'a\')]',
          tree: {
              tag: '123', ind1: nil, ind2: nil, subfield: nil,
              condition: {
                  cond_format: {
                      entry: [
                          {cond_group: {
                              prefix: 'f.match',
                              lparen: '(',
                              entry: [
                                  {cond_group: {
                                      prefix: nil,
                                      lparen: "'",
                                      entry: nil,
                                      postfix: 'a',
                                      rparen: "'"
                                  }}
                              ],
                              postfix: nil,
                              rparen: ')'
                          }}
                      ],
                      postfix: nil
                  }
              }
          },
          transform: "record.select_fields('123##', Proc.new { |f| f.match('a') })"
      }, {
          title: 'select statement with regex condition',
          input: 'MARC 123 [$0 =~ /^.+"ABC"/]',
          tree: {
              tag: '123', ind1: nil, ind2: nil, subfield: nil,
              condition: {
                  cond_format: {
                      entry: [
                          {subfield: {:prefix => nil, :repeat => nil, :name => '0'}},
                          {cond_group: {
                              prefix: ' =~ /^.+',
                              lparen: "\"",
                              entry: nil,
                              postfix: 'ABC',
                              rparen: "\""
                          }}
                      ],
                      postfix: '/'
                  }
              }
          },
          transform: "record.select_fields('123##', Proc.new { |f| f.subfield('0') =~ /^.+\"ABC\"/ })"
      }, {
          title: 'select statement with complex regex condition',
          input: 'MARC 690 02 {$0 =~ /^\(ODIS-(PS|ORG)\) (\d)+$$/}',
          tree: {
              tag: '690', ind1: '0', ind2: '2', subfield: nil,
              condition: {
                  cond_format: {
                      entry: [
                          {subfield: {prefix: nil, repeat: nil, name: '0'}},
                          {cond_group: {prefix: " =~ /^\\",
                                        lparen: '(',
                                        entry: [
                                            {cond_group: {
                                                prefix: 'ODIS-',
                                                lparen: '(',
                                                entry: nil,
                                                postfix: 'PS|ORG',
                                                rparen: ')'}}
                                        ],
                                        postfix: "\\",
                                        rparen: ')'}},
                          {cond_group: {
                              prefix: ' ',
                              lparen: '(',
                              entry: nil,
                              postfix: "\\d",
                              rparen: ')'}}
                      ],
                      postfix: '+$$/'}}
          },
          transform: "record.select_fields('69002', Proc.new { |f| f.subfield('0') =~ /^\\(ODIS-(PS|ORG)\\) (\\d)+$$/ })"
      }, {
      }, {
          title: 'format statement with simple subfield reference',
          input: '$a',
          tree: {entry: [{subfield: {prefix: nil, repeat: nil, name: 'a'}}], postfix: nil},
          transform: "f.subfield('a')"
      }, {
          title: 'format statement with subfield reference with repeat indicator',
          input: '$*a',
          tree: {entry: [{subfield: {prefix: nil, repeat: '*', name: 'a'}}], postfix: nil},
          transform: "field_format(f.subfield_array('a'), join: ';').to_s"
      }, {
          title: 'format statement with subfield reference with repeat + separator indicator',
          input: '$*"; "a',
          tree: {entry: [{subfield: {prefix: nil, repeat: {separator: '; '}, name: 'a'}}], postfix: nil},
          transform: "field_format(f.subfield_array('a'), join: '; ').to_s"
      }, {
          title: 'format statement with position reference',
          input: '$[13]',
          tree: {entry: [{fixfield: {prefix: nil, position: '13'}}], postfix: nil},
          transform: 'f[13]'
      }, {
          title: 'format statement with range reference',
          input: 'abc: $[5-8]',
          tree: {entry: [{fixfield: {prefix: 'abc: ', first: '5', last: '8'}}], postfix: nil},
          transform: "field_format(f[5,8], prefix: 'abc: ').to_s"
      }, {
          title: 'format statement with all range reference',
          input: 'abc: $[*].',
          tree: {entry: [{fixfield: {prefix: 'abc: ', all: '*'}}], postfix: '.'},
          transform: "field_format(field_format(f[], prefix: 'abc: ').to_s, postfix: '.').to_s"
      }, {
          title: 'format statement with multiple subfields with prefixes',
          input: '$a, $b - $c',
          tree: {
              entry: [
                  {subfield: {prefix: nil, repeat: nil, name: 'a'}},
                  {subfield: {prefix: ', ', repeat: nil, name: 'b'}},
                  {subfield: {prefix: ' - ', repeat: nil, name: 'c'}},
              ],
              postfix: nil},
          transform: "field_format(f.subfield('a'),field_format(f.subfield('b'), prefix: ', ').to_s,field_format(f.subfield('c'), prefix: ' - ').to_s).to_s"
      }, {
          title: 'format statement with multiple subfields with prefixes and postfix',
          input: '$a, $b - $c.',
          tree: {
              entry: [
                  {subfield: {prefix: nil, repeat: nil, name: 'a'}},
                  {subfield: {prefix: ', ', repeat: nil, name: 'b'}},
                  {subfield: {prefix: ' - ', repeat: nil, name: 'c'}},
              ],
              postfix: '.'},
          transform: "field_format(f.subfield('a'),field_format(f.subfield('b'), prefix: ', ').to_s,field_format(f.subfield('c'), prefix: ' - ').to_s, postfix: '.').to_s"
      }, {
          title: 'format statement with multiple subfields with prefixes and group',
          input: '$a, $b - ($c)',
          tree: {
              entry: [
                  {subfield: {prefix: nil, repeat: nil, name: 'a'}},
                  {subfield: {prefix: ', ', repeat: nil, name: 'b'}},
                  {group: {
                      prefix: ' - ', postfix: nil,
                      lparen: '(', rparen: ')',
                      entry: [{subfield: {prefix: nil, repeat: nil, name: 'c'}}]
                  }},
              ],
              postfix: nil},
          transform: "field_format(f.subfield('a'),field_format(f.subfield('b'), prefix: ', ').to_s,field_format(f.subfield('c'), prefix: ' - (', postfix: ')').to_s).to_s"
      }, {
          title: 'format statement with multiple subfields with prefixes and group with multiple entries',
          input: '$a, $b - ($c, $d, ...)',
          tree: {
              entry: [
                  {subfield: {prefix: nil, repeat: nil, name: 'a'}},
                  {subfield: {prefix: ', ', repeat: nil, name: 'b'}},
                  {group: {
                      prefix: ' - ', postfix: ', ...',
                      lparen: '(', rparen: ')',
                      entry: [
                          {subfield: {prefix: nil, repeat: nil, name: 'c'}},
                          {subfield: {prefix: ', ', repeat: nil, name: 'd'}},
                      ],
                  }},
              ],
              postfix: nil},
          transform: "field_format(f.subfield('a'),field_format(f.subfield('b'), prefix: ', ').to_s,field_format(f.subfield('c'),field_format(f.subfield('d'), prefix: ', ').to_s, prefix: ' - (', postfix: ', ...)').to_s).to_s"
      }, {
          title: 'format statement with nested groups',
          input: '([{{($a)}}])',
          tree: {
              entry: [
                  {group: {
                      prefix: nil, postfix: nil,
                      lparen: '(', rparen: ')',
                      entry: [
                          {group: {
                              prefix: nil, postfix: nil,
                              lparen: '[', rparen: ']',
                              entry: [
                                  {group: {
                                      prefix: nil, postfix: nil,
                                      lparen: '{', rparen: '}',
                                      entry: [
                                          {group: {
                                              prefix: nil, postfix: nil,
                                              lparen: '{', rparen: '}',
                                              entry: [
                                                  {group: {
                                                      prefix: nil, postfix: nil,
                                                      lparen: '(', rparen: ')',
                                                      entry: [{subfield: {prefix: nil, repeat: nil, name: 'a'}}]
                                                  }}
                                              ]
                                          }}
                                      ]
                                  }}
                              ]
                          }}
                      ]
                  }}
              ],
              postfix: nil},
          transform: "field_format(field_format(field_format(field_format(field_format(f.subfield('a'), prefix: '(', postfix: ')').to_s, prefix: '{', postfix: '}').to_s, prefix: '{', postfix: '}').to_s, prefix: '[', postfix: ']').to_s, prefix: '(', postfix: ')').to_s"
      }, {
          title: 'format statement with missing closing bracket',
          input: '($a',
          tree: :failure
      }, {
          title: 'format statement with missing opening bracket',
          input: '$a)',
          tree: :failure
      }, {
          title: 'format statement with nested quotes',
          input: ':"-$a, $*"+"b-".',
          tree: {
              entry: [
                  {group: {
                      prefix: ':', postfix: '-',
                      lparen: '"', rparen: '"',
                      entry: [
                          {subfield: {prefix: '-', repeat: nil, name: 'a'}},
                          {subfield: {prefix: ', ', repeat: {separator: '+'}, name: 'b'}}
                      ],
                  }}
              ],
              postfix: '.'},
          transform: "field_format(field_format(field_format(f.subfield('a'), prefix: '-').to_s,field_format(f.subfield_array('b'), prefix: ', ', join: '+').to_s, prefix: ':\"', postfix: '-\"').to_s, postfix: '.').to_s"
      }, {
          title: 'format statement with double dollar prefix and postfix',
          input: 'ab: $$$*a$$.',
          tree: {
              entry: [{subfield: {prefix: 'ab: $$', repeat: '*', name: 'a'}}],
              postfix: '$$.'},
          transform: "field_format(field_format(f.subfield_array('a'), prefix: 'ab: $$', join: ';').to_s, postfix: '$$.').to_s"
      }, {
          title: 'format statement with condition text',
          input: '$0 =~ /^\(ODIS-(PS|ORG)\) (\d)+$$/',
          tree: {
              entry: [
                  {subfield: {prefix: nil, repeat: nil, name: '0'}},
                  {group: {
                      prefix: ' =~ /^\\', postfix: '\\',
                      lparen: '(', rparen: ')',
                      entry: [
                          {group: {
                              prefix: 'ODIS-', postfix: 'PS|ORG',
                              lparen: '(', rparen: ')',
                              entry: nil
                          }}
                      ]
                  }},
                  {group: {
                      prefix: ' ', postfix: '\\d',
                      lparen: '(', rparen: ')',
                      entry: nil
                  }}
              ],
              postfix: '+$$/'},
          transform: "field_format(f.subfield('0'),field_format(field_format(, prefix: 'ODIS-(', postfix: 'PS|ORG)').to_s, prefix: ' =~ /^\\(', postfix: '\\)').to_s,field_format(, prefix: ' (', postfix: '\\d)').to_s, postfix: '+$$/').to_s"
      }, {
          title: 'format statement with method call',
          input: '$(my_method($a,$b))',
          tree: {entry: [
              {method_call: {
                  prefix: nil, postfix: nil,
                  entry: [
                      {group: {
                          prefix: 'my_method', postfix: nil,
                          lparen: '(', rparen: ')',
                          entry: [
                              {subfield: {prefix: nil, repeat: nil, name: 'a'}},
                              {subfield: {prefix: ',', repeat: nil, name: 'b'}}
                          ]
                      }}
                  ]
              }}
          ],
                 postfix: nil},
          transform: {:format => {:entry => [{:method_call => {:prefix => nil, :entry => ["field_format(f.subfield('a'),field_format(f.subfield('b'), prefix: ',').to_s, prefix: 'my_method(', postfix: ')').to_s"], :postfix => nil}}], :postfix => nil}}
      }, {
          title: 'format statement with complex with method call',
          input: "$a $b ($c) ($d) ($g), $(lookup('DOLLAR4','Name','Tag'=>'100','Code'=>$4.to_s)) ($9)",
          tree: {entry: [
              {subfield: {prefix: nil, repeat: nil, name: 'a'}},
              {subfield: {prefix: ' ', repeat: nil, name: 'b'}},
              {group: {
                  prefix: ' ', postfix: nil,
                  lparen: '(', rparen: ')',
                  entry: [{subfield: {prefix: nil, repeat: nil, name: 'c'}}]}},
              {group: {
                  prefix: ' ', postfix: nil,
                  lparen: '(', rparen: ')',
                  entry: [{subfield: {prefix: nil, repeat: nil, name: 'd'}}]
              }},
              {group: {
                  prefix: ' ', postfix: nil,
                  lparen: '(', rparen: ')',
                  entry: [{subfield: {prefix: nil, repeat: nil, name: 'g'}}]
              }},
              {method_call: {
                  prefix: ', ', postfix: nil,
                  entry: [
                      {group: {
                          prefix: 'lookup', postfix: '.to_s',
                          lparen: '(', rparen: ')',
                          entry: [
                              {group: {prefix: nil, lparen: "'", entry: nil, postfix: 'DOLLAR4', rparen: "'"}},
                              {group: {prefix: ',', lparen: "'", entry: nil, postfix: 'Name', rparen: "'"}},
                              {group: {prefix: ',', lparen: "'", entry: nil, postfix: 'Tag', rparen: "'"}},
                              {group: {prefix: '=>', lparen: "'", entry: nil, postfix: '100', rparen: "'"}},
                              {group: {prefix: ',', lparen: "'", entry: nil, postfix: 'Code', rparen: "'"}},
                              {subfield: {prefix: '=>', repeat: nil, name: '4'}}
                          ]
                      }}
                  ]
              }},
              {group: {
                  prefix: ' ', postfix: nil,
                  lparen: '(', rparen: ')',
                  entry: [{subfield: {prefix: nil, repeat: nil, name: '9'}}]
              }}
          ],
                 postfix: nil},
          transform: {:format => {:entry => ["f.subfield('a')", "field_format(f.subfield('b'), prefix: ' ').to_s", "field_format(f.subfield('c'), prefix: ' (', postfix: ')').to_s", "field_format(f.subfield('d'), prefix: ' (', postfix: ')').to_s", "field_format(f.subfield('g'), prefix: ' (', postfix: ')').to_s", {:method_call => {:prefix => ', ', :entry => ["field_format(field_format(, prefix: ''', postfix: 'DOLLAR4'').to_s,field_format(, prefix: ','', postfix: 'Name'').to_s,field_format(, prefix: ','', postfix: 'Tag'').to_s,field_format(, prefix: '=>'', postfix: '100'').to_s,field_format(, prefix: ','', postfix: 'Code'').to_s,field_format(f.subfield('4'), prefix: '=>').to_s, prefix: 'lookup(', postfix: '.to_s)').to_s"], :postfix => nil}}, "field_format(f.subfield('9'), prefix: ' (', postfix: ')').to_s"], :postfix => nil}}
      }
  ]
end
