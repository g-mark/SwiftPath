# JSONPath Compliance Test Suite Report

Source: [`Tests/SwiftPathTests/Resources/cts.json`](Tests/SwiftPathTests/Resources/cts.json)

Total: **703** — pass: **465**, fail: **0**, known-failure: **238**, unexpected-pass: **0**

| Test                                                         | Status |
| ------------------------------------------------------------ | ------ |
| index selector, overflowing index<br />`$[231584178474632390847141970017375815706539969331281128078915168015826259279872]` | ✅      |



| Name | Path | Status |
|------|------|--------|
| basic, root | `$` | known-failure |
| basic, no leading whitespace | ` $` | pass |
| basic, no trailing whitespace | `$ ` | pass |
| basic, name shorthand | `$.a` | pass |
| basic, name shorthand, extended unicode ☺ | `$.☺` | known-failure |
| basic, name shorthand, underscore | `$._` | pass |
| basic, name shorthand, symbol | `$.&` | pass |
| basic, name shorthand, number | `$.1` | pass |
| basic, name shorthand, absent data | `$.c` | pass |
| basic, name shorthand, array data | `$.a` | pass |
| basic, name shorthand, object data, nested | `$.a.b.c` | pass |
| basic, wildcard shorthand, object data | `$.*` | pass |
| basic, wildcard shorthand, array data | `$.*` | pass |
| basic, wildcard selector, array data | `$[*]` | pass |
| basic, wildcard shorthand, then name shorthand | `$.*.a` | pass |
| basic, multiple selectors | `$[0,2]` | pass |
| basic, multiple selectors, space instead of comma | `$[0 2]` | pass |
| basic, selector, leading comma | `$[,0]` | pass |
| basic, selector, trailing comma | `$[0,]` | pass |
| basic, multiple selectors, name and index, array data | `$['a',1]` | known-failure |
| basic, multiple selectors, name and index, object data | `$['a',1]` | known-failure |
| basic, multiple selectors, index and slice | `$[1,5:7]` | known-failure |
| basic, multiple selectors, index and slice, overlapping | `$[1,0:3]` | known-failure |
| basic, multiple selectors, duplicate index | `$[1,1]` | pass |
| basic, multiple selectors, wildcard and index | `$[*,1]` | known-failure |
| basic, multiple selectors, wildcard and name | `$[*,'a']` | known-failure |
| basic, multiple selectors, wildcard and slice | `$[*,0:2]` | known-failure |
| basic, multiple selectors, multiple wildcards | `$[*,*]` | known-failure |
| basic, empty segment | `$[]` | pass |
| basic, descendant segment, index | `$..[1]` | known-failure |
| basic, descendant segment, name shorthand | `$..a` | known-failure |
| basic, name shorthand, true | `$.true` | pass |
| basic, name shorthand, false | `$.false` | pass |
| basic, name shorthand, null | `$.null` | pass |
| basic, descendant segment, wildcard shorthand, array data | `$..*` | known-failure |
| basic, descendant segment, wildcard selector, array data | `$..[*]` | known-failure |
| basic, descendant segment, wildcard selector, nested arrays | `$..[*]` | known-failure |
| basic, descendant segment, wildcard selector, nested objects | `$..[*]` | known-failure |
| basic, descendant segment, wildcard shorthand, object data | `$..*` | known-failure |
| basic, descendant segment, wildcard shorthand, nested data | `$..*` | known-failure |
| basic, descendant segment, multiple selectors | `$..['a','d']` | known-failure |
| basic, descendant segment, object traversal, multiple selectors | `$..['a','d']` | known-failure |
| basic, bald descendant segment | `$..` | pass |
| basic, current node identifier without filter selector | `$[@.a]` | pass |
| basic, root node identifier in brackets without filter selector | `$[$.a]` | pass |
| filter, existence, without segments | `$[?@]` | known-failure |
| filter, existence | `$[?@.a]` | pass |
| filter, existence, present with null | `$[?@.a]` | pass |
| filter, absolute existence, without segments | `$[?$]` | known-failure |
| filter, absolute existence, with segments | `$[?$.*.a]` | pass |
| filter, equals string, single quotes | `$[?@.a=='b']` | pass |
| filter, equals numeric string, single quotes | `$[?@.a=='1']` | pass |
| filter, equals string, double quotes | `$[?@.a=="b"]` | pass |
| filter, equals numeric string, double quotes | `$[?@.a=="1"]` | pass |
| filter, equals number | `$[?@.a==1]` | pass |
| filter, equals null | `$[?@.a==null]` | pass |
| filter, equals null, absent from data | `$[?@.a==null]` | pass |
| filter, equals true | `$[?@.a==true]` | pass |
| filter, equals false | `$[?@.a==false]` | pass |
| filter, equals self | `$[?@==@]` | known-failure |
| filter, absolute, equals self | `$[?$==$]` | known-failure |
| filter, equals, absent from index selector equals absent from name selector | `$[?@.absent==@.list[9]]` | known-failure |
| filter, deep equality, arrays | `$[?@.a==@.b]` | known-failure |
| filter, deep equality, objects | `$[?@.a==@.b]` | known-failure |
| filter, not-equals string, single quotes | `$[?@.a!='b']` | pass |
| filter, not-equals numeric string, single quotes | `$[?@.a!='1']` | pass |
| filter, not-equals string, single quotes, different type | `$[?@.a!='b']` | pass |
| filter, not-equals string, double quotes | `$[?@.a!="b"]` | pass |
| filter, not-equals numeric string, double quotes | `$[?@.a!="1"]` | pass |
| filter, not-equals string, double quotes, different types | `$[?@.a!="b"]` | pass |
| filter, not-equals number | `$[?@.a!=1]` | pass |
| filter, not-equals number, different types | `$[?@.a!=1]` | pass |
| filter, not-equals null | `$[?@.a!=null]` | pass |
| filter, not-equals null, absent from data | `$[?@.a!=null]` | known-failure |
| filter, not-equals true | `$[?@.a!=true]` | pass |
| filter, not-equals false | `$[?@.a!=false]` | pass |
| filter, less than string, single quotes | `$[?@.a<'c']` | known-failure |
| filter, less than string, double quotes | `$[?@.a<"c"]` | known-failure |
| filter, less than number | `$[?@.a<10]` | pass |
| filter, less than null | `$[?@.a<null]` | pass |
| filter, less than true | `$[?@.a<true]` | pass |
| filter, less than false | `$[?@.a<false]` | pass |
| filter, less than or equal to string, single quotes | `$[?@.a<='c']` | known-failure |
| filter, less than or equal to string, double quotes | `$[?@.a<="c"]` | known-failure |
| filter, less than or equal to number | `$[?@.a<=10]` | pass |
| filter, less than or equal to null | `$[?@.a<=null]` | known-failure |
| filter, less than or equal to true | `$[?@.a<=true]` | pass |
| filter, less than or equal to false | `$[?@.a<=false]` | pass |
| filter, greater than string, single quotes | `$[?@.a>'c']` | known-failure |
| filter, greater than string, double quotes | `$[?@.a>"c"]` | known-failure |
| filter, greater than number | `$[?@.a>10]` | pass |
| filter, greater than null | `$[?@.a>null]` | pass |
| filter, greater than true | `$[?@.a>true]` | pass |
| filter, greater than false | `$[?@.a>false]` | pass |
| filter, greater than or equal to string, single quotes | `$[?@.a>='c']` | known-failure |
| filter, greater than or equal to string, double quotes | `$[?@.a>="c"]` | known-failure |
| filter, greater than or equal to number | `$[?@.a>=10]` | pass |
| filter, greater than or equal to null | `$[?@.a>=null]` | known-failure |
| filter, greater than or equal to true | `$[?@.a>=true]` | pass |
| filter, greater than or equal to false | `$[?@.a>=false]` | pass |
| filter, exists and not-equals null, absent from data | `$[?@.a&&@.a!=null]` | pass |
| filter, exists and exists, data false | `$[?@.a&&@.b]` | pass |
| filter, exists or exists, data false | `$[?@.a||@.b]` | pass |
| filter, and | `$[?@.a>0&&@.a<10]` | pass |
| filter, or | `$[?@.a=='b'||@.a=='d']` | pass |
| filter, not expression | `$[?!(@.a=='b')]` | pass |
| filter, not exists | `$[?!@.a]` | pass |
| filter, not exists, data null | `$[?!@.a]` | pass |
| filter, non-singular existence, wildcard | `$[?@.*]` | known-failure |
| filter, non-singular existence, multiple | `$[?@[0, 0, 'a']]` | known-failure |
| filter, non-singular existence, slice | `$[?@[0:2]]` | known-failure |
| filter, non-singular existence, negated | `$[?!@.*]` | known-failure |
| filter, non-singular query in comparison, slice | `$[?@[0:0]==0]` | pass |
| filter, non-singular query in comparison, all children | `$[?@[*]==0]` | pass |
| filter, non-singular query in comparison, descendants | `$[?@..a==0]` | pass |
| filter, non-singular query in comparison, combined | `$[?@.a[*].a==0]` | pass |
| filter, nested | `$[?@[?@>1]]` | known-failure |
| filter, name segment on primitive, selects nothing | `$[?@.a == 1]` | known-failure |
| filter, name segment on array, selects nothing | `$[?@['0'] == 5]` | pass |
| filter, index segment on object, selects nothing | `$[?@[0] == 5]` | known-failure |
| filter, followed by name selector | `$[?@.a==1].b.x` | pass |
| filter, followed by child segment that selects multiple elements | `$[?@.z=='_']['x','y']` | known-failure |
| filter, relative non-singular query, index, equal | `$[?(@[0, 0]==42)]` | pass |
| filter, relative non-singular query, index, not equal | `$[?(@[0, 0]!=42)]` | pass |
| filter, relative non-singular query, index, less-or-equal | `$[?(@[0, 0]<=42)]` | pass |
| filter, relative non-singular query, name, equal | `$[?(@['a', 'a']==42)]` | pass |
| filter, relative non-singular query, name, not equal | `$[?(@['a', 'a']!=42)]` | pass |
| filter, relative non-singular query, name, less-or-equal | `$[?(@['a', 'a']<=42)]` | pass |
| filter, relative non-singular query, combined, equal | `$[?(@[0, '0']==42)]` | pass |
| filter, relative non-singular query, combined, not equal | `$[?(@[0, '0']!=42)]` | pass |
| filter, relative non-singular query, combined, less-or-equal | `$[?(@[0, '0']<=42)]` | pass |
| filter, relative non-singular query, wildcard, equal | `$[?(@.*==42)]` | known-failure |
| filter, relative non-singular query, wildcard, not equal | `$[?(@.*!=42)]` | known-failure |
| filter, relative non-singular query, wildcard, less-or-equal | `$[?(@.*<=42)]` | known-failure |
| filter, relative non-singular query, slice, equal | `$[?(@[0:0]==42)]` | pass |
| filter, relative non-singular query, slice, not equal | `$[?(@[0:0]!=42)]` | pass |
| filter, relative non-singular query, slice, less-or-equal | `$[?(@[0:0]<=42)]` | pass |
| filter, absolute non-singular query, index, equal | `$[?($[0, 0]==42)]` | pass |
| filter, absolute non-singular query, index, not equal | `$[?($[0, 0]!=42)]` | pass |
| filter, absolute non-singular query, index, less-or-equal | `$[?($[0, 0]<=42)]` | pass |
| filter, absolute non-singular query, name, equal | `$[?($['a', 'a']==42)]` | pass |
| filter, absolute non-singular query, name, not equal | `$[?($['a', 'a']!=42)]` | pass |
| filter, absolute non-singular query, name, less-or-equal | `$[?($['a', 'a']<=42)]` | pass |
| filter, absolute non-singular query, combined, equal | `$[?($[0, '0']==42)]` | pass |
| filter, absolute non-singular query, combined, not equal | `$[?($[0, '0']!=42)]` | pass |
| filter, absolute non-singular query, combined, less-or-equal | `$[?($[0, '0']<=42)]` | pass |
| filter, absolute non-singular query, wildcard, equal | `$[?($.*==42)]` | known-failure |
| filter, absolute non-singular query, wildcard, not equal | `$[?($.*!=42)]` | known-failure |
| filter, absolute non-singular query, wildcard, less-or-equal | `$[?($.*<=42)]` | known-failure |
| filter, absolute non-singular query, slice, equal | `$[?($[0:0]==42)]` | pass |
| filter, absolute non-singular query, slice, not equal | `$[?($[0:0]!=42)]` | pass |
| filter, absolute non-singular query, slice, less-or-equal | `$[?($[0:0]<=42)]` | pass |
| filter, multiple selectors | `$[?@.a,?@.b]` | known-failure |
| filter, multiple selectors, comparison | `$[?@.a=='b',?@.b=='x']` | known-failure |
| filter, multiple selectors, overlapping | `$[?@.a,?@.d]` | known-failure |
| filter, multiple selectors, filter and index | `$[?@.a,1]` | known-failure |
| filter, multiple selectors, filter and wildcard | `$[?@.a,*]` | known-failure |
| filter, multiple selectors, filter and slice | `$[?@.a,1:]` | known-failure |
| filter, multiple selectors, comparison filter, index and slice | `$[1, ?@.a=='b', 1:]` | known-failure |
| filter, equals number, zero and negative zero | `$[?@.a==0]` | pass |
| filter, equals number, negative zero and zero | `$[?@.a==-0]` | pass |
| filter, equals number, with and without decimal fraction | `$[?@.a==1.0]` | pass |
| filter, equals number, exponent | `$[?@.a==1e2]` | known-failure |
| filter, equals number, exponent upper e | `$[?@.a==1E2]` | known-failure |
| filter, equals number, positive exponent | `$[?@.a==1e+2]` | known-failure |
| filter, equals number, negative exponent | `$[?@.a==1e-2]` | known-failure |
| filter, equals number, exponent 0 | `$[?@.a==1e0]` | known-failure |
| filter, equals number, exponent -0 | `$[?@.a==1e-0]` | known-failure |
| filter, equals number, exponent +0 | `$[?@.a==1e+0]` | known-failure |
| filter, equals number, exponent leading -0 | `$[?@.a==1e-02]` | known-failure |
| filter, equals number, exponent +00 | `$[?@.a==1e+00]` | known-failure |
| filter, equals number, decimal fraction | `$[?@.a==1.1]` | pass |
| filter, equals number, decimal fraction, trailing 0 | `$[?@.a==1.10]` | pass |
| filter, equals number, decimal fraction, exponent | `$[?@.a==1.1e2]` | known-failure |
| filter, equals number, decimal fraction, positive exponent | `$[?@.a==1.1e+2]` | known-failure |
| filter, equals number, decimal fraction, negative exponent | `$[?@.a==1.1e-2]` | known-failure |
| filter, equals number, invalid plus | `$[?@.a==+1]` | pass |
| filter, equals number, invalid minus space | `$[?@.a==- 1]` | pass |
| filter, equals number, invalid double minus | `$[?@.a==--1]` | pass |
| filter, equals number, invalid no int digit | `$[?@.a==.1]` | pass |
| filter, equals number, invalid minus no int digit | `$[?@.a==-.1]` | pass |
| filter, equals number, invalid 00 | `$[?@.a==00]` | known-failure |
| filter, equals number, invalid leading 0 | `$[?@.a==01]` | known-failure |
| filter, equals number, invalid no fractional digit | `$[?@.a==1.]` | pass |
| filter, equals number, invalid middle minus | `$[?@.a==1.-1]` | pass |
| filter, equals number, invalid no fractional digit e | `$[?@.a==1.e1]` | pass |
| filter, equals number, invalid no e digit | `$[?@.a==1e]` | pass |
| filter, equals number, invalid no e digit minus | `$[?@.a==1e-]` | pass |
| filter, equals number, invalid double e | `$[?@.a==1eE1]` | pass |
| filter, equals number, invalid e digit double minus | `$[?@.a==1e--1]` | pass |
| filter, equals number, invalid e digit plus minus | `$[?@.a==1e+-1]` | pass |
| filter, equals number, invalid e decimal | `$[?@.a==1e2.3]` | pass |
| filter, equals number, invalid multi e | `$[?@.a==1e2e3]` | pass |
| filter, equals, special nothing | `$.values[?length(@.a) == value($..c)]` | known-failure |
| filter, equals, empty node list and empty node list | `$[?@.a == @.b]` | known-failure |
| filter, equals, empty node list and special nothing | `$[?@.a == length(@.b)]` | known-failure |
| filter, object data | `$[?@<3]` | known-failure |
| filter, two consecutive ands | `$[?@.a && @.b && @.c]` | pass |
| filter, two consecutive ors | `$[?@.a || @.b || @.c]` | pass |
| filter, multiple consecutive ands | `$[?@.a && @.b && @.c && @.d && @.e]` | pass |
| filter, multiple consecutive ors | `$[?@.a || @.b || @.c || @.d || @.e]` | pass |
| filter, multiple consecutive ors and ands | `$[?@.a && @.b && @.c || @.d || @.e]` | pass |
| filter, and binds more tightly than or | `$[?@.a || @.b && @.c]` | pass |
| filter, left to right evaluation | `$[?@.a && @.b || @.c]` | pass |
| filter, group terms, left | `$[?(@.a || @.b) && @.c]` | pass |
| filter, group terms, right | `$[?@.a && (@.b || @.c)]` | pass |
| filter, string literal, single quote in double quotes | `$[?@ == "quoted' literal"]` | pass |
| filter, string literal, double quote in single quotes | `$[?@ == 'quoted" literal']` | pass |
| filter, string literal, escaped single quote in single quotes | `$[?@ == 'quoted\\' literal']` | known-failure |
| filter, string literal, escaped double quote in double quotes | `$[?@ == "quoted\\" literal"]` | known-failure |
| filter, literal true must be compared | `$[?true]` | pass |
| filter, literal false must be compared | `$[?false]` | pass |
| filter, literal string must be compared | `$[?'abc']` | pass |
| filter, literal int must be compared | `$[?2]` | pass |
| filter, literal float must be compared | `$[?2.2]` | pass |
| filter, literal null must be compared | `$[?null]` | pass |
| filter, and, literals must be compared | `$[?true && false]` | pass |
| filter, or, literals must be compared | `$[?true || false]` | pass |
| filter, and, right hand literal must be compared | `$[?true == false && false]` | pass |
| filter, or, right hand literal must be compared | `$[?true == false || false]` | pass |
| filter, and, left hand literal must be compared | `$[?false && true == false]` | pass |
| filter, or, left hand literal must be compared | `$[?false || true == false]` | pass |
| filter, true, incorrectly capitalized | `$[?@==True]` | pass |
| filter, quoted True, double quotes | `$[?@.a=="True"]` | pass |
| filter, quoted True, single quotes | `$[?@.a=='True']` | pass |
| filter, false, incorrectly capitalized | `$[?@==False]` | pass |
| filter, quoted False, double quotes | `$[?@.a=="False"]` | pass |
| filter, quoted False, single quotes | `$[?@.a=='False']` | pass |
| filter, null, incorrectly capitalized | `$[?@==Null]` | pass |
| filter, quoted Null, double quotes | `$[?@.a=="Null"]` | pass |
| filter, quoted Null, single quotes | `$[?@.a=='Null']` | pass |
| index selector, first element | `$[0]` | pass |
| index selector, second element | `$[1]` | pass |
| index selector, out of bound | `$[2]` | pass |
| index selector, min exact index | `$[-9007199254740991]` | pass |
| index selector, max exact index | `$[9007199254740991]` | pass |
| index selector, min exact index - 1 | `$[-9007199254740992]` | pass |
| index selector, max exact index + 1 | `$[9007199254740992]` | pass |
| index selector, overflowing index | `$[231584178474632390847141970017375815706539969331281128078915168015826259279872]` | pass |
| index selector, not actually an index, overflowing index leads into general text | `$[231584178474632390847141970017375815706539969331281128078915168SomeRandomText]` | pass |
| index selector, negative | `$[-1]` | pass |
| index selector, more negative | `$[-2]` | pass |
| index selector, negative out of bound | `$[-3]` | pass |
| index selector, on object | `$[0]` | pass |
| index selector, leading 0 | `$[01]` | pass |
| index selector, decimal | `$[1.0]` | pass |
| index selector, plus | `$[+1]` | pass |
| index selector, minus space | `$[- 1]` | pass |
| index selector, -0 | `$[-0]` | pass |
| index selector, leading -0 | `$[-01]` | pass |
| name selector, double quotes | `$["a"]` | pass |
| name selector, double quotes, absent data | `$["c"]` | pass |
| name selector, double quotes, array data | `$["a"]` | pass |
| name selector, name, double quotes, contains single quote | `$["a'"]` | pass |
| name selector, name, double quotes, nested | `$["a"]["b"]["c"]` | pass |
| name selector, double quotes, embedded U+0000 | `$[" "]` | pass |
| name selector, double quotes, embedded U+0001 | `$[""]` | pass |
| name selector, double quotes, embedded U+0002 | `$[""]` | pass |
| name selector, double quotes, embedded U+0003 | `$[""]` | pass |
| name selector, double quotes, embedded U+0004 | `$[""]` | pass |
| name selector, double quotes, embedded U+0005 | `$[""]` | pass |
| name selector, double quotes, embedded U+0006 | `$[""]` | pass |
| name selector, double quotes, embedded U+0007 | `$[""]` | pass |
| name selector, double quotes, embedded U+0008 | `$[""]` | pass |
| name selector, double quotes, embedded U+0009 | `$["\t"]` | pass |
| name selector, double quotes, embedded U+000A | `$["\n"]` | pass |
| name selector, double quotes, embedded U+000B | `$[""]` | pass |
| name selector, double quotes, embedded U+000C | `$[""]` | pass |
| name selector, double quotes, embedded U+000D | `$["\r"]` | pass |
| name selector, double quotes, embedded U+000E | `$[""]` | pass |
| name selector, double quotes, embedded U+000F | `$[""]` | pass |
| name selector, double quotes, embedded U+0010 | `$[""]` | pass |
| name selector, double quotes, embedded U+0011 | `$[""]` | pass |
| name selector, double quotes, embedded U+0012 | `$[""]` | pass |
| name selector, double quotes, embedded U+0013 | `$[""]` | pass |
| name selector, double quotes, embedded U+0014 | `$[""]` | pass |
| name selector, double quotes, embedded U+0015 | `$[""]` | pass |
| name selector, double quotes, embedded U+0016 | `$[""]` | pass |
| name selector, double quotes, embedded U+0017 | `$[""]` | pass |
| name selector, double quotes, embedded U+0018 | `$[""]` | pass |
| name selector, double quotes, embedded U+0019 | `$[""]` | pass |
| name selector, double quotes, embedded U+001A | `$[""]` | pass |
| name selector, double quotes, embedded U+001B | `$[""]` | pass |
| name selector, double quotes, embedded U+001C | `$[""]` | pass |
| name selector, double quotes, embedded U+001D | `$[""]` | pass |
| name selector, double quotes, embedded U+001E | `$[""]` | pass |
| name selector, double quotes, embedded U+001F | `$[""]` | pass |
| name selector, double quotes, embedded U+0020 | `$[" "]` | pass |
| name selector, double quotes, embedded U+007F | `$[""]` | pass |
| name selector, double quotes, supplementary plane character | `$["𝄞"]` | pass |
| name selector, double quotes, escaped double quote | `$["\\""]` | pass |
| name selector, double quotes, escaped reverse solidus | `$["\\\\"]` | pass |
| name selector, double quotes, escaped solidus | `$["\\/"]` | pass |
| name selector, double quotes, escaped backspace | `$["\\b"]` | pass |
| name selector, double quotes, escaped form feed | `$["\\f"]` | pass |
| name selector, double quotes, escaped line feed | `$["\\n"]` | pass |
| name selector, double quotes, escaped carriage return | `$["\\r"]` | pass |
| name selector, double quotes, escaped tab | `$["\\t"]` | pass |
| name selector, double quotes, escaped ☺, upper case hex | `$["\\u263A"]` | pass |
| name selector, double quotes, escaped ☺, lower case hex | `$["\\u263a"]` | pass |
| name selector, double quotes, surrogate pair 𝄞 | `$["\\uD834\\uDD1E"]` | pass |
| name selector, double quotes, surrogate pair 😀 | `$["\\uD83D\\uDE00"]` | pass |
| name selector, double quotes, before high surrogates | `$["\\uD7FF\\uD7FF"]` | pass |
| name selector, double quotes, after low surrogates | `$["\\uE000\\uE000"]` | pass |
| name selector, double quotes, invalid escaped single quote | `$["\\'"]` | pass |
| name selector, double quotes, embedded double quote | `$["""]` | pass |
| name selector, double quotes, incomplete escape | `$["\\"]` | pass |
| name selector, double quotes, escape at end of line | `$["\\\n"]` | pass |
| name selector, double quotes, question mark escape | `$["\\?"]` | pass |
| name selector, double quotes, bell escape | `$["\\a"]` | pass |
| name selector, double quotes, vertical tab escape | `$["\\v"]` | pass |
| name selector, double quotes, 0 escape | `$["\\0"]` | pass |
| name selector, double quotes, x escape | `$["\\x12"]` | pass |
| name selector, double quotes, n escape | `$["\\N{LATIN CAPITAL LETTER A}"]` | pass |
| name selector, double quotes, unicode escape no hex | `$["\\u"]` | pass |
| name selector, double quotes, unicode escape too few hex | `$["\\u123"]` | pass |
| name selector, double quotes, unicode escape upper u | `$["\\U1234"]` | pass |
| name selector, double quotes, unicode escape upper u long | `$["\\U0010FFFF"]` | pass |
| name selector, double quotes, unicode escape plus | `$["\\u+1234"]` | pass |
| name selector, double quotes, unicode escape brackets | `$["\\u{1234}"]` | pass |
| name selector, double quotes, unicode escape brackets long | `$["\\u{10ffff}"]` | pass |
| name selector, double quotes, single high surrogate | `$["\\uD800"]` | pass |
| name selector, double quotes, single low surrogate | `$["\\uDC00"]` | pass |
| name selector, double quotes, high high surrogate | `$["\\uD800\\uD800"]` | pass |
| name selector, double quotes, low low surrogate | `$["\\uDC00\\uDC00"]` | pass |
| name selector, double quotes, surrogate non-surrogate | `$["\\uD800\\u1234"]` | pass |
| name selector, double quotes, non-surrogate surrogate | `$["\\u1234\\uDC00"]` | pass |
| name selector, double quotes, surrogate supplementary | `$["\\uD800𝄞"]` | pass |
| name selector, double quotes, supplementary surrogate | `$["𝄞\\uDC00"]` | pass |
| name selector, double quotes, surrogate incomplete low | `$["\\uD800\\uDC0"]` | pass |
| name selector, single quotes | `$['a']` | pass |
| name selector, single quotes, absent data | `$['c']` | pass |
| name selector, single quotes, array data | `$['a']` | pass |
| name selector, single quotes, embedded U+0000 | `$[' ']` | pass |
| name selector, single quotes, embedded U+0001 | `$['']` | pass |
| name selector, single quotes, embedded U+0002 | `$['']` | pass |
| name selector, single quotes, embedded U+0003 | `$['']` | pass |
| name selector, single quotes, embedded U+0004 | `$['']` | pass |
| name selector, single quotes, embedded U+0005 | `$['']` | pass |
| name selector, single quotes, embedded U+0006 | `$['']` | pass |
| name selector, single quotes, embedded U+0007 | `$['']` | pass |
| name selector, single quotes, embedded U+0008 | `$['']` | pass |
| name selector, single quotes, embedded U+0009 | `$['\t']` | pass |
| name selector, single quotes, embedded U+000A | `$['\n']` | pass |
| name selector, single quotes, embedded U+000B | `$['']` | pass |
| name selector, single quotes, embedded U+000C | `$['']` | pass |
| name selector, single quotes, embedded U+000D | `$['\r']` | pass |
| name selector, single quotes, embedded U+000E | `$['']` | pass |
| name selector, single quotes, embedded U+000F | `$['']` | pass |
| name selector, single quotes, embedded U+0010 | `$['']` | pass |
| name selector, single quotes, embedded U+0011 | `$['']` | pass |
| name selector, single quotes, embedded U+0012 | `$['']` | pass |
| name selector, single quotes, embedded U+0013 | `$['']` | pass |
| name selector, single quotes, embedded U+0014 | `$['']` | pass |
| name selector, single quotes, embedded U+0015 | `$['']` | pass |
| name selector, single quotes, embedded U+0016 | `$['']` | pass |
| name selector, single quotes, embedded U+0017 | `$['']` | pass |
| name selector, single quotes, embedded U+0018 | `$['']` | pass |
| name selector, single quotes, embedded U+0019 | `$['']` | pass |
| name selector, single quotes, embedded U+001A | `$['']` | pass |
| name selector, single quotes, embedded U+001B | `$['']` | pass |
| name selector, single quotes, embedded U+001C | `$['']` | pass |
| name selector, single quotes, embedded U+001D | `$['']` | pass |
| name selector, single quotes, embedded U+001E | `$['']` | pass |
| name selector, single quotes, embedded U+001F | `$['']` | pass |
| name selector, single quotes, embedded U+0020 | `$[' ']` | pass |
| name selector, single quotes, escaped single quote | `$['\\'']` | pass |
| name selector, single quotes, escaped reverse solidus | `$['\\\\']` | pass |
| name selector, single quotes, escaped solidus | `$['\\/']` | pass |
| name selector, single quotes, escaped backspace | `$['\\b']` | pass |
| name selector, single quotes, escaped form feed | `$['\\f']` | pass |
| name selector, single quotes, escaped line feed | `$['\\n']` | pass |
| name selector, single quotes, escaped carriage return | `$['\\r']` | pass |
| name selector, single quotes, escaped tab | `$['\\t']` | pass |
| name selector, single quotes, escaped ☺, upper case hex | `$['\\u263A']` | pass |
| name selector, single quotes, escaped ☺, lower case hex | `$['\\u263a']` | pass |
| name selector, single quotes, surrogate pair 𝄞 | `$['\\uD834\\uDD1E']` | pass |
| name selector, single quotes, surrogate pair 😀 | `$['\\uD83D\\uDE00']` | pass |
| name selector, single quotes, invalid escaped double quote | `$['\\"']` | pass |
| name selector, single quotes, embedded single quote | `$[''']` | pass |
| name selector, single quotes, incomplete escape | `$['\\']` | pass |
| name selector, double quotes, empty | `$[""]` | pass |
| name selector, single quotes, empty | `$['']` | pass |
| slice selector, slice selector | `$[1:3]` | pass |
| slice selector, slice selector with step | `$[1:6:2]` | pass |
| slice selector, slice selector with everything omitted, short form | `$[:]` | pass |
| slice selector, slice selector with everything omitted, long form | `$[::]` | pass |
| slice selector, slice selector with start omitted | `$[:2]` | pass |
| slice selector, slice selector with start and end omitted | `$[::2]` | pass |
| slice selector, negative step with default start and end | `$[::-1]` | pass |
| slice selector, negative step with default start | `$[:0:-1]` | pass |
| slice selector, negative step with default end | `$[2::-1]` | pass |
| slice selector, larger negative step | `$[::-2]` | pass |
| slice selector, negative range with default step | `$[-1:-3]` | pass |
| slice selector, negative range with negative step | `$[-1:-3:-1]` | pass |
| slice selector, negative range with larger negative step | `$[-1:-6:-2]` | pass |
| slice selector, larger negative range with larger negative step | `$[-1:-7:-2]` | pass |
| slice selector, negative from, positive to | `$[-5:7]` | pass |
| slice selector, negative from | `$[-2:]` | pass |
| slice selector, positive from, negative to | `$[1:-1]` | pass |
| slice selector, negative from, positive to, negative step | `$[-1:1:-1]` | pass |
| slice selector, positive from, negative to, negative step | `$[7:-5:-1]` | pass |
| slice selector, in serial, on nested array | `$[1:3][1:2]` | known-failure |
| slice selector, in serial, on flat array | `$[1:3][::]` | known-failure |
| slice selector, negative from, negative to, positive step | `$[-5:-2]` | pass |
| slice selector, too many colons | `$[1:2:3:4]` | pass |
| slice selector, non-integer array index | `$[1:2:a]` | pass |
| slice selector, zero step | `$[1:2:0]` | pass |
| slice selector, empty range | `$[2:2]` | pass |
| slice selector, slice selector with everything omitted with empty array | `$[:]` | pass |
| slice selector, negative step with empty array | `$[::-1]` | pass |
| slice selector, maximal range with positive step | `$[0:10]` | pass |
| slice selector, maximal range with negative step | `$[9:0:-1]` | pass |
| slice selector, excessively large to value | `$[2:113667776004]` | pass |
| slice selector, excessively small from value | `$[-113667776004:1]` | pass |
| slice selector, excessively large from value with negative step | `$[113667776004:0:-1]` | pass |
| slice selector, excessively small to value with negative step | `$[3:-113667776004:-1]` | pass |
| slice selector, excessively large step | `$[1:10:113667776004]` | pass |
| slice selector, excessively small step | `$[-1:-10:-113667776004]` | pass |
| slice selector, start, min exact | `$[-9007199254740991::]` | pass |
| slice selector, start, max exact | `$[9007199254740991::]` | pass |
| slice selector, start, min exact - 1 | `$[-9007199254740992::]` | pass |
| slice selector, start, max exact + 1 | `$[9007199254740992::]` | pass |
| slice selector, end, min exact | `$[:-9007199254740991:]` | pass |
| slice selector, end, max exact | `$[:9007199254740991:]` | pass |
| slice selector, end, min exact - 1 | `$[:-9007199254740992:]` | pass |
| slice selector, end, max exact + 1 | `$[:9007199254740992:]` | pass |
| slice selector, step, min exact | `$[::-9007199254740991]` | pass |
| slice selector, step, max exact | `$[::9007199254740991]` | pass |
| slice selector, step, min exact - 1 | `$[::-9007199254740992]` | pass |
| slice selector, step, max exact + 1 | `$[::9007199254740992]` | pass |
| slice selector, overflowing to value | `$[2:231584178474632390847141970017375815706539969331281128078915168015826259279872]` | pass |
| slice selector, underflowing from value | `$[-231584178474632390847141970017375815706539969331281128078915168015826259279872:1]` | pass |
| slice selector, overflowing from value with negative step | `$[231584178474632390847141970017375815706539969331281128078915168015826259279872:0:-1]` | pass |
| slice selector, underflowing to value with negative step | `$[3:-231584178474632390847141970017375815706539969331281128078915168015826259279872:-1]` | pass |
| slice selector, overflowing step | `$[1:10:231584178474632390847141970017375815706539969331281128078915168015826259279872]` | pass |
| slice selector, underflowing step | `$[-1:-10:-231584178474632390847141970017375815706539969331281128078915168015826259279872]` | pass |
| slice selector, start, leading 0 | `$[01::]` | pass |
| slice selector, start, decimal | `$[1.0::]` | pass |
| slice selector, start, plus | `$[+1::]` | pass |
| slice selector, start, minus space | `$[- 1::]` | pass |
| slice selector, start, -0 | `$[-0::]` | pass |
| slice selector, start, leading -0 | `$[-01::]` | pass |
| slice selector, end, leading 0 | `$[:01:]` | pass |
| slice selector, end, decimal | `$[:1.0:]` | pass |
| slice selector, end, plus | `$[:+1:]` | pass |
| slice selector, end, minus space | `$[:- 1:]` | pass |
| slice selector, end, -0 | `$[:-0:]` | pass |
| slice selector, end, leading -0 | `$[:-01:]` | pass |
| slice selector, step, leading 0 | `$[::01]` | pass |
| slice selector, step, decimal | `$[::1.0]` | pass |
| slice selector, step, plus | `$[::+1]` | pass |
| slice selector, step, minus space | `$[::- 1]` | pass |
| slice selector, step, -0 | `$[::-0]` | pass |
| slice selector, step, leading -0 | `$[::-01]` | pass |
| functions, count, count function | `$[?count(@..*)>2]` | known-failure |
| functions, count, single-node arg | `$[?count(@.a)>1]` | known-failure |
| functions, count, multiple-selector arg | `$[?count(@['a','d'])>1]` | known-failure |
| functions, count, non-query arg, number | `$[?count(1)>2]` | pass |
| functions, count, non-query arg, string | `$[?count('string')>2]` | pass |
| functions, count, non-query arg, true | `$[?count(true)>2]` | pass |
| functions, count, non-query arg, false | `$[?count(false)>2]` | pass |
| functions, count, non-query arg, null | `$[?count(null)>2]` | pass |
| functions, count, result must be compared | `$[?count(@..*)]` | pass |
| functions, count, no params | `$[?count()==1]` | pass |
| functions, count, too many params | `$[?count(@.a,@.b)==1]` | pass |
| functions, length, string data | `$[?length(@.a)>=2]` | known-failure |
| functions, length, string data, unicode | `$[?length(@)==2]` | known-failure |
| functions, length, array data | `$[?length(@.a)>=2]` | known-failure |
| functions, length, missing data | `$[?length(@.a)>=2]` | known-failure |
| functions, length, number arg | `$[?length(1)>=2]` | known-failure |
| functions, length, true arg | `$[?length(true)>=2]` | known-failure |
| functions, length, false arg | `$[?length(false)>=2]` | known-failure |
| functions, length, null arg | `$[?length(null)>=2]` | known-failure |
| functions, length, result must be compared | `$[?length(@.a)]` | pass |
| functions, length, no params | `$[?length()==1]` | pass |
| functions, length, too many params | `$[?length(@.a,@.b)==1]` | pass |
| functions, length, non-singular query arg | `$[?length(@.*)<3]` | pass |
| functions, length, arg is a function expression | `$.values[?length(@.a)==length(value($..c))]` | known-failure |
| functions, length, arg is special nothing | `$[?length(value(@.a))>0]` | known-failure |
| functions, length, non-singular query arg, multiple index selectors | `$[?length(@[1, 2])<3]` | pass |
| functions, length, non-singular query arg, multiple name selectors | `$[?length(@['a', 'b'])<3]` | pass |
| functions, match, found match | `$[?match(@.a, 'a.*')]` | known-failure |
| functions, match, double quotes | `$[?match(@.a, "a.*")]` | known-failure |
| functions, match, regex from the document | `$.values[?match(@, $.regex)]` | known-failure |
| functions, match, don't select match | `$[?!match(@.a, 'a.*')]` | known-failure |
| functions, match, not a match | `$[?match(@.a, 'a.*')]` | known-failure |
| functions, match, select non-match | `$[?!match(@.a, 'a.*')]` | known-failure |
| functions, match, non-string first arg | `$[?match(1, 'a.*')]` | known-failure |
| functions, match, non-string second arg | `$[?match(@.a, 1)]` | known-failure |
| functions, match, filter, match function, unicode char class, uppercase | `$[?match(@, '\\\\p{Lu}')]` | known-failure |
| functions, match, filter, match function, unicode char class negated, uppercase | `$[?match(@, '\\\\P{Lu}')]` | known-failure |
| functions, match, filter, match function, unicode, surrogate pair | `$[?match(@, 'a.b')]` | known-failure |
| functions, match, dot matcher on \\u2028 | `$[?match(@, '.')]` | known-failure |
| functions, match, dot matcher on \\u2029 | `$[?match(@, '.')]` | known-failure |
| functions, match, result cannot be compared | `$[?match(@.a, 'a.*')==true]` | pass |
| functions, match, too few params | `$[?match(@.a)==1]` | pass |
| functions, match, too many params | `$[?match(@.a,@.b,@.c)==1]` | pass |
| functions, match, arg is a function expression | `$.values[?match(@.a, value($..['regex']))]` | known-failure |
| functions, match, dot in character class | `$[?match(@, 'a[.b]c')]` | known-failure |
| functions, match, escaped dot | `$[?match(@, 'a\\\\.c')]` | known-failure |
| functions, match, escaped backslash before dot | `$[?match(@, 'a\\\\\\\\.c')]` | known-failure |
| functions, match, escaped left square bracket | `$[?match(@, 'a\\\\[.c')]` | known-failure |
| functions, match, escaped right square bracket | `$[?match(@, 'a[\\\\].]c')]` | known-failure |
| functions, match, explicit caret | `$[?match(@, '^ab.*')]` | known-failure |
| functions, match, explicit dollar | `$[?match(@, '.*bc$')]` | known-failure |
| functions, search, at the end | `$[?search(@.a, 'a.*')]` | known-failure |
| functions, search, double quotes | `$[?search(@.a, "a.*")]` | known-failure |
| functions, search, at the start | `$[?search(@.a, 'a.*')]` | known-failure |
| functions, search, in the middle | `$[?search(@.a, 'a.*')]` | known-failure |
| functions, search, regex from the document | `$.values[?search(@, $.regex)]` | known-failure |
| functions, search, don't select match | `$[?!search(@.a, 'a.*')]` | known-failure |
| functions, search, not a match | `$[?search(@.a, 'a.*')]` | known-failure |
| functions, search, select non-match | `$[?!search(@.a, 'a.*')]` | known-failure |
| functions, search, non-string first arg | `$[?search(1, 'a.*')]` | known-failure |
| functions, search, non-string second arg | `$[?search(@.a, 1)]` | known-failure |
| functions, search, filter, search function, unicode char class, uppercase | `$[?search(@, '\\\\p{Lu}')]` | known-failure |
| functions, search, filter, search function, unicode char class negated, uppercase | `$[?search(@, '\\\\P{Lu}')]` | known-failure |
| functions, search, filter, search function, unicode, surrogate pair | `$[?search(@, 'a.b')]` | known-failure |
| functions, search, dot matcher on \\u2028 | `$[?search(@, '.')]` | known-failure |
| functions, search, dot matcher on \\u2029 | `$[?search(@, '.')]` | known-failure |
| functions, search, result cannot be compared | `$[?search(@.a, 'a.*')==true]` | pass |
| functions, search, too few params | `$[?search(@.a)]` | pass |
| functions, search, too many params | `$[?search(@.a,@.b,@.c)]` | pass |
| functions, search, arg is a function expression | `$.values[?search(@, value($..['regex']))]` | known-failure |
| functions, search, dot in character class | `$[?search(@, 'a[.b]c')]` | known-failure |
| functions, search, escaped dot | `$[?search(@, 'a\\\\.c')]` | known-failure |
| functions, search, escaped backslash before dot | `$[?search(@, 'a\\\\\\\\.c')]` | known-failure |
| functions, search, escaped left square bracket | `$[?search(@, 'a\\\\[.c')]` | known-failure |
| functions, search, escaped right square bracket | `$[?search(@, 'a[\\\\].]c')]` | known-failure |
| functions, value, single-value nodelist | `$[?value(@.*)==4]` | known-failure |
| functions, value, multi-value nodelist | `$[?value(@.*)==4]` | known-failure |
| functions, value, too few params | `$[?value()==4]` | pass |
| functions, value, too many params | `$[?value(@.a,@.b)==4]` | pass |
| functions, value, result must be compared | `$[?value(@.a)]` | pass |
| whitespace, filter, space between question mark and expression | `$[? @.a]` | pass |
| whitespace, filter, newline between question mark and expression | `$[?\n@.a]` | pass |
| whitespace, filter, tab between question mark and expression | `$[?\t@.a]` | pass |
| whitespace, filter, return between question mark and expression | `$[?\r@.a]` | pass |
| whitespace, filter, space between question mark and parenthesized expression | `$[? (@.a)]` | pass |
| whitespace, filter, newline between question mark and parenthesized expression | `$[?\n(@.a)]` | pass |
| whitespace, filter, tab between question mark and parenthesized expression | `$[?\t(@.a)]` | pass |
| whitespace, filter, return between question mark and parenthesized expression | `$[?\r(@.a)]` | pass |
| whitespace, filter, space between parenthesized expression and bracket | `$[?(@.a) ]` | pass |
| whitespace, filter, newline between parenthesized expression and bracket | `$[?(@.a)\n]` | pass |
| whitespace, filter, tab between parenthesized expression and bracket | `$[?(@.a)\t]` | pass |
| whitespace, filter, return between parenthesized expression and bracket | `$[?(@.a)\r]` | pass |
| whitespace, filter, space between bracket and question mark | `$[ ?@.a]` | pass |
| whitespace, filter, newline between bracket and question mark | `$[\n?@.a]` | pass |
| whitespace, filter, tab between bracket and question mark | `$[\t?@.a]` | pass |
| whitespace, filter, return between bracket and question mark | `$[\r?@.a]` | pass |
| whitespace, functions, space between function name and parenthesis | `$[?count (@.*)==1]` | pass |
| whitespace, functions, newline between function name and parenthesis | `$[?count\n(@.*)==1]` | pass |
| whitespace, functions, tab between function name and parenthesis | `$[?count\t(@.*)==1]` | pass |
| whitespace, functions, return between function name and parenthesis | `$[?count\r(@.*)==1]` | pass |
| whitespace, functions, space between parenthesis and arg | `$[?count( @.*)==1]` | known-failure |
| whitespace, functions, newline between parenthesis and arg | `$[?count(\n@.*)==1]` | known-failure |
| whitespace, functions, tab between parenthesis and arg | `$[?count(\t@.*)==1]` | known-failure |
| whitespace, functions, return between parenthesis and arg | `$[?count(\r@.*)==1]` | known-failure |
| whitespace, functions, space between arg and comma | `$[?search(@ ,'[a-z]+')]` | known-failure |
| whitespace, functions, newline between arg and comma | `$[?search(@\n,'[a-z]+')]` | known-failure |
| whitespace, functions, tab between arg and comma | `$[?search(@\t,'[a-z]+')]` | known-failure |
| whitespace, functions, return between arg and comma | `$[?search(@\r,'[a-z]+')]` | known-failure |
| whitespace, functions, space between comma and arg | `$[?search(@, '[a-z]+')]` | known-failure |
| whitespace, functions, newline between comma and arg | `$[?search(@,\n'[a-z]+')]` | known-failure |
| whitespace, functions, tab between comma and arg | `$[?search(@,\t'[a-z]+')]` | known-failure |
| whitespace, functions, return between comma and arg | `$[?search(@,\r'[a-z]+')]` | known-failure |
| whitespace, functions, space between arg and parenthesis | `$[?count(@.* )==1]` | known-failure |
| whitespace, functions, newline between arg and parenthesis | `$[?count(@.*\n)==1]` | known-failure |
| whitespace, functions, tab between arg and parenthesis | `$[?count(@.*\t)==1]` | known-failure |
| whitespace, functions, return between arg and parenthesis | `$[?count(@.*\r)==1]` | known-failure |
| whitespace, functions, spaces in a relative singular selector | `$[?length(@ .a .b) == 3]` | known-failure |
| whitespace, functions, newlines in a relative singular selector | `$[?length(@\n.a\n.b) == 3]` | known-failure |
| whitespace, functions, tabs in a relative singular selector | `$[?length(@\t.a\t.b) == 3]` | known-failure |
| whitespace, functions, returns in a relative singular selector | `$[?length(@\r.a\r.b) == 3]` | known-failure |
| whitespace, functions, spaces in an absolute singular selector | `$..[?length(@)==length($ [0] .a)]` | known-failure |
| whitespace, functions, newlines in an absolute singular selector | `$..[?length(@)==length($\n[0]\n.a)]` | known-failure |
| whitespace, functions, tabs in an absolute singular selector | `$..[?length(@)==length($\t[0]\t.a)]` | known-failure |
| whitespace, functions, returns in an absolute singular selector | `$..[?length(@)==length($\r[0]\r.a)]` | known-failure |
| whitespace, operators, space before \|\| | `$[?@.a ||@.b]` | pass |
| whitespace, operators, newline before \|\| | `$[?@.a\n||@.b]` | pass |
| whitespace, operators, tab before \|\| | `$[?@.a\t||@.b]` | pass |
| whitespace, operators, return before \|\| | `$[?@.a\r||@.b]` | pass |
| whitespace, operators, space after \|\| | `$[?@.a|| @.b]` | pass |
| whitespace, operators, newline after \|\| | `$[?@.a||\n@.b]` | pass |
| whitespace, operators, tab after \|\| | `$[?@.a||\t@.b]` | pass |
| whitespace, operators, return after \|\| | `$[?@.a||\r@.b]` | pass |
| whitespace, operators, space before && | `$[?@.a &&@.b]` | pass |
| whitespace, operators, newline before && | `$[?@.a\n&&@.b]` | pass |
| whitespace, operators, tab before && | `$[?@.a\t&&@.b]` | pass |
| whitespace, operators, return before && | `$[?@.a\r&&@.b]` | pass |
| whitespace, operators, space after && | `$[?@.a&& @.b]` | pass |
| whitespace, operators, newline after && | `$[?@.a&& @.b]` | pass |
| whitespace, operators, tab after && | `$[?@.a&& @.b]` | pass |
| whitespace, operators, return after && | `$[?@.a&& @.b]` | pass |
| whitespace, operators, space before == | `$[?@.a ==@.b]` | known-failure |
| whitespace, operators, newline before == | `$[?@.a\n==@.b]` | known-failure |
| whitespace, operators, tab before == | `$[?@.a\t==@.b]` | known-failure |
| whitespace, operators, return before == | `$[?@.a\r==@.b]` | known-failure |
| whitespace, operators, space after == | `$[?@.a== @.b]` | known-failure |
| whitespace, operators, newline after == | `$[?@.a==\n@.b]` | known-failure |
| whitespace, operators, tab after == | `$[?@.a==\t@.b]` | known-failure |
| whitespace, operators, return after == | `$[?@.a==\r@.b]` | known-failure |
| whitespace, operators, space before != | `$[?@.a !=@.b]` | known-failure |
| whitespace, operators, newline before != | `$[?@.a\n!=@.b]` | known-failure |
| whitespace, operators, tab before != | `$[?@.a\t!=@.b]` | known-failure |
| whitespace, operators, return before != | `$[?@.a\r!=@.b]` | known-failure |
| whitespace, operators, space after != | `$[?@.a!= @.b]` | known-failure |
| whitespace, operators, newline after != | `$[?@.a!=\n@.b]` | known-failure |
| whitespace, operators, tab after != | `$[?@.a!=\t@.b]` | known-failure |
| whitespace, operators, return after != | `$[?@.a!=\r@.b]` | known-failure |
| whitespace, operators, space before < | `$[?@.a <@.b]` | known-failure |
| whitespace, operators, newline before < | `$[?@.a\n<@.b]` | known-failure |
| whitespace, operators, tab before < | `$[?@.a\t<@.b]` | known-failure |
| whitespace, operators, return before < | `$[?@.a\r<@.b]` | known-failure |
| whitespace, operators, space after < | `$[?@.a< @.b]` | known-failure |
| whitespace, operators, newline after < | `$[?@.a<\n@.b]` | known-failure |
| whitespace, operators, tab after < | `$[?@.a<\t@.b]` | known-failure |
| whitespace, operators, return after < | `$[?@.a<\r@.b]` | known-failure |
| whitespace, operators, space before > | `$[?@.b >@.a]` | known-failure |
| whitespace, operators, newline before > | `$[?@.b\n>@.a]` | known-failure |
| whitespace, operators, tab before > | `$[?@.b\t>@.a]` | known-failure |
| whitespace, operators, return before > | `$[?@.b\r>@.a]` | known-failure |
| whitespace, operators, space after > | `$[?@.b> @.a]` | known-failure |
| whitespace, operators, newline after > | `$[?@.b>\n@.a]` | known-failure |
| whitespace, operators, tab after > | `$[?@.b>\t@.a]` | known-failure |
| whitespace, operators, return after > | `$[?@.b>\r@.a]` | known-failure |
| whitespace, operators, space before <= | `$[?@.a <=@.b]` | known-failure |
| whitespace, operators, newline before <= | `$[?@.a\n<=@.b]` | known-failure |
| whitespace, operators, tab before <= | `$[?@.a\t<=@.b]` | known-failure |
| whitespace, operators, return before <= | `$[?@.a\r<=@.b]` | known-failure |
| whitespace, operators, space after <= | `$[?@.a<= @.b]` | known-failure |
| whitespace, operators, newline after <= | `$[?@.a<=\n@.b]` | known-failure |
| whitespace, operators, tab after <= | `$[?@.a<=\t@.b]` | known-failure |
| whitespace, operators, return after <= | `$[?@.a<=\r@.b]` | known-failure |
| whitespace, operators, space before >= | `$[?@.b >=@.a]` | known-failure |
| whitespace, operators, newline before >= | `$[?@.b\n>=@.a]` | known-failure |
| whitespace, operators, tab before >= | `$[?@.b\t>=@.a]` | known-failure |
| whitespace, operators, return before >= | `$[?@.b\r>=@.a]` | known-failure |
| whitespace, operators, space after >= | `$[?@.b>= @.a]` | known-failure |
| whitespace, operators, newline after >= | `$[?@.b>=\n@.a]` | known-failure |
| whitespace, operators, tab after >= | `$[?@.b>=\t@.a]` | known-failure |
| whitespace, operators, return after >= | `$[?@.b>=\r@.a]` | known-failure |
| whitespace, operators, space between logical not and test expression | `$[?! @.a]` | pass |
| whitespace, operators, newline between logical not and test expression | `$[?!\n@.a]` | pass |
| whitespace, operators, tab between logical not and test expression | `$[?!\t@.a]` | pass |
| whitespace, operators, return between logical not and test expression | `$[?!\r@.a]` | pass |
| whitespace, operators, space between logical not and parenthesized expression | `$[?! (@.a=='b')]` | pass |
| whitespace, operators, newline between logical not and parenthesized expression | `$[?!\n(@.a=='b')]` | pass |
| whitespace, operators, tab between logical not and parenthesized expression | `$[?!\t(@.a=='b')]` | pass |
| whitespace, operators, return between logical not and parenthesized expression | `$[?!\r(@.a=='b')]` | pass |
| whitespace, selectors, space between root and bracket | `$ ['a']` | known-failure |
| whitespace, selectors, newline between root and bracket | `$\n['a']` | known-failure |
| whitespace, selectors, tab between root and bracket | `$\t['a']` | known-failure |
| whitespace, selectors, return between root and bracket | `$\r['a']` | known-failure |
| whitespace, selectors, space between bracket and bracket | `$['a'] ['b']` | known-failure |
| whitespace, selectors, newline between bracket and bracket | `$['a'] \n['b']` | known-failure |
| whitespace, selectors, tab between bracket and bracket | `$['a'] \t['b']` | known-failure |
| whitespace, selectors, return between bracket and bracket | `$['a'] \r['b']` | known-failure |
| whitespace, selectors, space between root and dot | `$ .a` | known-failure |
| whitespace, selectors, newline between root and dot | `$\n.a` | known-failure |
| whitespace, selectors, tab between root and dot | `$\t.a` | known-failure |
| whitespace, selectors, return between root and dot | `$\r.a` | known-failure |
| whitespace, selectors, space between dot and name | `$. a` | pass |
| whitespace, selectors, newline between dot and name | `$.\na` | pass |
| whitespace, selectors, tab between dot and name | `$.\ta` | pass |
| whitespace, selectors, return between dot and name | `$.\ra` | pass |
| whitespace, selectors, space between recursive descent and name | `$.. a` | pass |
| whitespace, selectors, newline between recursive descent and name | `$..\na` | pass |
| whitespace, selectors, tab between recursive descent and name | `$..\ta` | pass |
| whitespace, selectors, return between recursive descent and name | `$..\ra` | pass |
| whitespace, selectors, space between bracket and selector | `$[ 'a']` | pass |
| whitespace, selectors, newline between bracket and selector | `$[\n'a']` | pass |
| whitespace, selectors, tab between bracket and selector | `$[\t'a']` | pass |
| whitespace, selectors, return between bracket and selector | `$[\r'a']` | pass |
| whitespace, selectors, space between selector and bracket | `$['a' ]` | pass |
| whitespace, selectors, newline between selector and bracket | `$['a'\n]` | pass |
| whitespace, selectors, tab between selector and bracket | `$['a'\t]` | pass |
| whitespace, selectors, return between selector and bracket | `$['a'\r]` | pass |
| whitespace, selectors, space between selector and comma | `$['a' ,'b']` | known-failure |
| whitespace, selectors, newline between selector and comma | `$['a'\n,'b']` | known-failure |
| whitespace, selectors, tab between selector and comma | `$['a'\t,'b']` | known-failure |
| whitespace, selectors, return between selector and comma | `$['a'\r,'b']` | known-failure |
| whitespace, selectors, space between comma and selector | `$['a', 'b']` | known-failure |
| whitespace, selectors, newline between comma and selector | `$['a',\n'b']` | known-failure |
| whitespace, selectors, tab between comma and selector | `$['a',\t'b']` | known-failure |
| whitespace, selectors, return between comma and selector | `$['a',\r'b']` | known-failure |
| whitespace, slice, space between start and colon | `$[1 :5:2]` | pass |
| whitespace, slice, newline between start and colon | `$[1\n:5:2]` | known-failure |
| whitespace, slice, tab between start and colon | `$[1\t:5:2]` | pass |
| whitespace, slice, return between start and colon | `$[1\r:5:2]` | known-failure |
| whitespace, slice, space between colon and end | `$[1: 5:2]` | pass |
| whitespace, slice, newline between colon and end | `$[1:\n5:2]` | known-failure |
| whitespace, slice, tab between colon and end | `$[1:\t5:2]` | pass |
| whitespace, slice, return between colon and end | `$[1:\r5:2]` | known-failure |
| whitespace, slice, space between end and colon | `$[1:5 :2]` | pass |
| whitespace, slice, newline between end and colon | `$[1:5\n:2]` | known-failure |
| whitespace, slice, tab between end and colon | `$[1:5\t:2]` | pass |
| whitespace, slice, return between end and colon | `$[1:5\r:2]` | known-failure |
| whitespace, slice, space between colon and step | `$[1:5: 2]` | pass |
| whitespace, slice, newline between colon and step | `$[1:5:\n2]` | known-failure |
| whitespace, slice, tab between colon and step | `$[1:5:\t2]` | pass |
| whitespace, slice, return between colon and step | `$[1:5:\r2]` | known-failure |
