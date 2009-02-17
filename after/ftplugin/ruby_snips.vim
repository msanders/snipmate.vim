if !exists('loaded_snips') || exists('b:did_ruby_snips')
	fini
en
let b:did_ruby_snips = 1

" New Block
exe "Snipp =b =begin rdoc\n\t${1}\n=end"
exe "Snipp y :yields: ${1:arguments}"
exe "Snipp rb #!/usr/bin/env ruby -wKU\n"
exe 'Snipp req require "${1}"${2}'
exe 'Snipp # # =>'
exe 'Snipp end __END__'
exe "Snipp case case ${1:object}\nwhen ${2:condition}\n\t${3}\nend"
exe "Snipp when when ${1:condition}\n\t${2}"
exe "Snipp def def ${1:method_name}\n\t${2}\nend"
exe "Snipp deft def test_${1:case_name}\n\t${2}\nend"
exe "Snipp if if ${1:condition}\n\t${2}\nend"
exe "Snipp ife if ${1:condition}\n\t${2}\nelse\n\t${3}\nend"
exe "Snipp elsif elsif ${1:condition}\n\t${2}"
exe "Snipp unless unless ${1:condition}\n\t${2}\nend"
exe "Snipp while while ${1:condition}\n\t${2}\nend"
exe "Snipp until until ${1:condition}\n\t${2}\nend"
exe "Snipp! cla \"class .. end\" class ${1:`substitute(Filename(), '^.', '\\u&', '')`}\n\t${2}\nend"
exe "Snipp! cla \"class .. initialize .. end\" class ${1:`substitute(Filename(), '^.', '\\u&', '')`}\n\tdef initialize(${2:args})\n\t\t${3}\n\tend\n\n\nend"
exe "Snipp! cla \"class .. < ParentClass .. initialize .. end\" class ${1:`substitute(Filename(), '^.', '\\u&', '')`} < ${2:ParentClass}\n\tdef initialize(${3:args})\n\t\t${4}\n\tend\n\n\nend"
exe "Snipp! cla \"ClassName = Struct .. do .. end\" ${1:`substitute(Filename(), '^.', '\\u&', '')`} = Struct.new(:${2:attr_names}) do\n\tdef ${3:method_name}\n\t\t${4}\n\tend\n\n\nend"
exe "Snipp! cla \"class BlankSlate .. initialize .. end\" class ${1:BlankSlate}\n\tinstance_methods.each { |meth| undef_method(meth) unless meth =~ /\A__/ }"
\ ."\n\n\tdef initialize(${2:args})\n\t\t@${3:delegate} = ${4:$3_object}\n\n\t\t${5}\n\tend\n\n\tdef method_missing(meth, *args, &block)\n\t\t@$3.send(meth, *args, &block)\n\tend\n\n\nend"
exe "Snipp! cla \"class << self .. end\" class << ${1:self}\n\t${2}\nend"
" class .. < DelegateClass .. initialize .. end
exe "Snipp cla- class ${1:`substitute(Filename(), '^.', '\\u&', '')`} < DelegateClass(${2:ParentClass})\n\tdef initialize(${3:args})\n\t\tsuper(${4:del_obj})\n\n\t\t${5}\n\tend\n\n\nend"
exe "Snipp! mod \"module .. end\" module ${1:`substitute(Filename(), '^.', '\\u&', '')`}\n\t${2}\nend"
exe "Snipp! mod \"module .. module_function .. end\" module ${1:`substitute(Filename(), '^.', '\\u&', '')`}\n\tmodule_function\n\n\t${2}\nend"
exe "Snipp! mod \"module .. ClassMethods .. end\" module ${1:`substitute(Filename(), '^.', '\\u&', '')`}\n\tmodule ClassMethods\n\t\t${2}\n\tend\n\n\t"
\."module InstanceMethods\n\n\tend\n\n\tdef self.included(receiver)\n\t\treceiver.extend         ClassMethods\n\t\treseiver.send :include, InstanceMethods\n\tend\nend"
" attr_reader
exe 'Snipp r attr_reader :${1:attr_names}'
" attr_writer
exe 'Snipp w attr_writer :${1:attr_names}'
" attr_accessor
exe 'Snipp rw attr_accessor :${1:attr_names}'
" include Enumerable
exe "Snipp Enum include Enumerable\n\ndef each(&block)\n\t${1}\nend"
" include Comparable
exe "Snipp Comp include Comparable\n\ndef <=>(other)\n\t${1}\nend"
" extend Forwardable
exe 'Snipp Forw- extend Forwardable'
" def self
exe "Snipp defs def self.${1:class_method_name}\n\t${2}\nend"
" def method_missing
exe "Snipp defmm def method_missing(meth, *args, &blk)\n\t${1}\nend"
exe 'Snipp defd def_delegator :${1:@del_obj}, :${2:del_meth}, :${3:new_name}'
exe 'Snipp defds def_delegators :${1:@del_obj}, :${2:del_methods}'
exe 'Snipp am alias_method :${1:new_name}, :${2:old_name}'
exe "Snipp app if __FILE__ == $PROGRAM_NAME\n\t${1}\nend"
" usage_if()
exe "Snipp usai if ARGV.${1}\n\tabort \"Usage: #{$PROGRAM_NAME} ${2:ARGS_GO_HERE}\"${3}\nend"
" usage_unless()
exe "Snipp usau unless ARGV.${1}\n\tabort \"Usage: #{$PROGRAM_NAME} ${2:ARGS_GO_HERE}\"${3}\nend"
exe 'Snipp array Array.new(${1:10}) { |${2:i}| ${3} }'
exe 'Snipp hash Hash.new { |${1:hash}, ${2:key}| $1[$2] = ${3} }'
exe 'Snipp! file "File.foreach() { |line| .. }" File.foreach(${1:"path/to/file"}) { |${2:line}| ${3} }'
exe 'Snipp! file "File.read()" File.read(${1:"path/to/file"})${2}'
exe 'Snipp! Dir "Dir.global() { |file| .. }" Dir.glob(${1:"dir/glob/*"}) { |${2:file}| ${3} }'
exe 'Snipp! Dir "Dir[''..'']" Dir[${1:"glob/**/*.rb"}]${2}'
exe 'Snipp dir Filename.dirname(__FILE__)'
exe 'Snipp deli delete_if { |${1:e}| ${2} }'
exe 'Snipp fil fill(${1:range}) { |${2:i}| ${3} }'
" flatten_once()
exe 'Snipp flao inject(Array.new) { |${1:arr}, ${2:a}| $1.push(*$2)}${3}'
exe 'Snipp zip zip(${1:enums}) { |${2:row}| ${3} }'
" downto(0) { |n| .. }
exe 'Snipp dow downto(${1:0}) { |${2:n}| ${3} }'
exe 'Snipp ste step(${1:2}) { |${2:n}| ${3} }'
exe 'Snipp tim times { |${1:n}| ${2} }'
exe 'Snipp upt upto(${1:1.0/0.0}) { |${2:n}| ${3} }'
exe 'Snipp loo loop { ${1} }'
exe 'Snipp ea each { |${1:e}| ${2} }'
exe 'Snipp eab each_byte { |${1:byte}| ${2} }'
exe 'Snipp! eac- "each_char { |chr| .. }" each_char { |${1:chr}| ${2} }'
exe 'Snipp! eac- "each_cons(..) { |group| .. }" each_cons(${1:2}) { |${2:group}| ${3} }'
exe 'Snipp eai each_index { |${1:i}| ${2} }'
exe 'Snipp eak each_key { |${1:key}| ${2} }'
exe 'Snipp eal each_line { |${1:line}| ${2} }'
exe 'Snipp eap each_pair { |${1:name}, ${2:val}| ${3} }'
exe 'Snipp eas- each_slice(${1:2}) { |${2:group}| ${3} }'
exe 'Snipp eav each_value { |${1:val}| ${2} }'
exe 'Snipp eawi each_with_index { |${1:e}, ${2:i}| ${3} }'
exe 'Snipp reve reverse_each { |${1:e}| ${2} }'
exe 'Snipp inj inject(${1:init}) { |${2:mem}, ${3:var}| ${4} }'
exe 'Snipp map map { |${1:e}| ${2} }'
exe 'Snipp mapwi- enum_with_index.map { |${1:e}, ${2:i}| ${3} }'
exe 'Snipp sor sort { |a, b| ${1} }'
exe 'Snipp sorb sort_by { |${1:e}| ${2} }'
exe 'Snipp ran sort_by { rand }'
exe 'Snipp all all? { |${1:e}| ${2} }'
exe 'Snipp any any? { |${1:e}| ${2} }'
exe 'Snipp cl classify { |${1:e}| ${2} }'
exe 'Snipp col collect { |${1:e}| ${2} }'
exe 'Snipp det detect { |${1:e}| ${2} }'
exe 'Snipp fet fetch(${1:name}) { |${2:key}| ${3} }'
exe 'Snipp fin find { |${1:e}| ${2} }'
exe 'Snipp fina find_all { |${1:e}| ${2} }'
exe 'Snipp gre grep(${1:/pattern/}) { |${2:match}| ${3} }'
exe 'Snipp sub ${1:g}sub(${2:/pattern/}) { |${3:match}| ${4} }'
exe 'Snipp sca scan(${1:/pattern/}) { |${2:match}| ${3} }'
exe 'Snipp max max { |a, b|, ${1} }'
exe 'Snipp min min { |a, b|, ${1} }'
exe 'Snipp par partition { |${1:e}|, ${2} }'
exe 'Snipp rej reject { |${1:e}|, ${2} }'
exe 'Snipp sel select { |${1:e}|, ${2} }'
exe 'Snipp lam lambda { |${1:args}| ${2} }'
exe "Snipp do do |${1:variable}|\n\t${2}\nend"
exe 'Snipp : :${1:key} => ${2:"value"}${3}'
exe 'Snipp ope open(${1:"path/or/url/or/pipe"}, "${2:w}") { |${3:io}| ${4} }'
" path_from_here()
exe 'Snipp patfh File.join(File.dirname(__FILE__), *%2[${1:rel path here}])${2}'
" unix_filter {}
exe "Snipp unif ARGF.each_line${1} do |${2:line}|\n\t${3}\nend"
" option_parse {}
exe "Snipp optp require \"optparse\"\n\noptions = {${1:default => \"args\"}}\n\nARGV.options do |opts|\n\topts.banner = \"Usage: #{File.basename($PROGRAM_NAME)}"
\."[OPTIONS] ${2:OTHER_ARGS}\"\n\n\topts.separator \"\"\n\topts.separator \"Specific Options:\"\n\n\t${3}\n\n\topts.separator \"Common Options:\"\n\n\t"
\."opts.on( \"-h\", \"--help\",\n           \"Show this message.\" ) do\n\t\tputs opts\n\t\texit\n\tend\n\n\tbegin\n\t\topts.parse!\n\trescue\n\t\tputs opts\n\t\texit\n\tend\nend"
exe "Snipp opt opts.on( \"-${1:o}\", \"--${2:long-option-name}\", ${3:String},\n         \"${4:Option description.}\") do |${5:opt}|\n\t${6}\nend"
exe "Snipp tc require \"test/unit\"\n\nrequire \"${1:library_file_name}\"\n\nclass Test${2:$1} < Test::Unit::TestCase\n\tdef test_${3:case_name}\n\t\t${4}\n\tend\nend"
exe "Snipp ts require \"test/unit\"\n\nrequire \"tc_${1:test_case_file}\"\nrequire \"tc_${2:test_case_file}\"${3}"
exe 'Snipp as assert(${1:test}, \"${2:Failure message.}\")${3}'
exe 'Snipp ase assert_equal(${1:expected}, ${2:actual})${3}'
exe 'Snipp asne assert_not_equal(${1:unexpected}, ${2:actual})${3}'
exe 'Snipp asid assert_in_delta(${1:expected_float}, ${2:actual_float}, ${3:2 ** -20})${4}'
exe 'Snipp asio assert_instance_of(${1:ExpectedClass}, ${2:actual_instance})${3}'
exe 'Snipp asko assert_kind_of(${1:ExpectedKind}, ${2:actual_instance})${3}'
exe 'Snipp asn assert_nil(${1:instance})${2}'
exe 'Snipp asnn assert_not_nil(${1:instance})${2}'
exe 'Snipp asm assert_match(/${1:expected_pattern}/, ${2:actual_string})${3}'
exe 'Snipp asnm assert_no_match(/${1:unexpected_pattern}/, ${2:actual_string})${3}'
exe 'Snipp aso assert_operator(${1:left}, :${2:operator}, ${3:right})${4}'
exe 'Snipp asr assert_raise(${1:Exception}) { ${2} }'
exe 'Snipp asnr assert_nothing_raised(${1:Exception}) { ${2} }'
exe 'Snipp asrt assert_respond_to(${1:object}, :${2:method})${3}'
exe 'Snipp! ass "assert_same(..)" assert_same(${1:expected}, ${2:actual})${3}'
exe 'Snipp! ass "assert_send(..)" assert_send([${1:object}, :${2:message}, ${3:args}])${4}'
exe 'Snipp asns assert_not_same(${1:unexpected}, ${2:actual})${3}'
exe 'Snipp ast assert_throws(:${1:expected}) { ${2} }'
exe 'Snipp asnt assert_nothing_thrown { ${1} }'
exe 'Snipp fl flunk("${1:Failure message.}")${2}'
" Benchmark.bmbm do .. end
exe "Snipp bm- TESTS = ${1:10_000}\nBenchmark.bmbm do |results|\n\t${2}\nend"
exe 'Snipp rep results.report("${1:name}:") { TESTS.times { ${2} }}'
" Marshal.dump(.., file)
exe 'Snipp Md File.open(${1:"path/to/file.dump"}, "wb") { |${2:file}| Marshal.dump(${3:obj}, $2) }${4}'
" Mashal.load(obj)
exe 'Snipp Ml File.open(${1:"path/to/file.dump"}, "rb") { |${2:file}| Marshal.load($2) }${3}'
" deep_copy(..)
exe 'Snipp deec Marshal.load(Marshal.dump(${1:obj_to_copy}))${2}'
exe 'Snipp Pn- PStore.new(${1:"file_name.pstore"})${2}'
exe 'Snipp tra transaction(${1:true}) { ${2} }'
" xmlread(..)
exe 'Snipp xml- REXML::Document.new(File.read(${1:"path/to/file"}))${2}'
" xpath(..) { .. }
exe "Snipp xpa elements.each(${1:\"//Xpath\"}) do |${2:node}|\n\t${3}\nend"
" class_from_name()
exe 'Snipp clafn split("::").inject(Object) { |par, const| par.const_get(const) }'
" singleton_class()
exe 'Snipp sinc class << self; self end'
exe "Snipp nam namespace :${1:`Filename()`} do\n\t${2}\nend"
exe "Snipp tas desc \"${1:Task description\}\"\ntask :${2:task_name => [:dependent, :tasks]} do\n\t${3}\nend"
