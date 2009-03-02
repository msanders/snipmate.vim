if !exists('loaded_snips') || exists('s:did_objc_snips')
	fini
en
let s:did_objc_snips = 1
let snippet_filetype = 'objc'

" #import <...>
exe 'Snipp imp #import <${1:Cocoa/Cocoa.h}>${2}'
" #import "..."
exe 'Snipp Imp #import "${1:`Filename()`.h}"${2}'
" @selector(...)
exe 'Snipp sel @selector(${1:method}:)${3}'
" NSLog(...)
exe 'Snipp log NSLog(@"${1}"${2});${3}'
" Class
exe "Snipp objc @interface ${1:`Filename('', 'object')`} : ${2:NSObject}\n{\n}\n@end\n\n@implementation $1\n- (id) init\n{\n\tif (self = [super init])"
\."\n\t{${3}\n\t}\n\treturn self\n}\n@end"
" Class Interface
exe "Snipp clh @interface ${1:ClassName} : ${2:NSObject}\n{${3}\n}\n${4}\n@end"
exe 'Snipp ibo IBOutlet ${1:NSSomeClass} *${2:$1};'
" Category
exe "Snipp cat @interface ${1:NSObject} (${2:Category})\n@end\n\n@implementation $1 ($2)\n${3}\n@end"
" Category Interface
exe "Snipp cath @interface ${1:NSObject} (${2:Category})\n${3}\n@end"
" NSArray
exe 'Snipp array NSMutableArray *${1:array} = [NSMutable array];${2}'
" NSDictionary
exe 'Snipp dict NSMutableDictionary *${1:dict} = [NSMutableDictionary dictionary];${2}'
" NSBezierPath
exe 'Snipp bez NSBezierPath *${1:path} = [NSBezierPath bezierPath];${2}'
" Method
exe "Snipp m - (${1:id})${2:method}\n{\n\t${3:return self;}\n}"
" Method declaration
exe "Snipp md - (${1:id})${2:method};${3}"
" Class Method
exe "Snipp M + (${1:id})${2:method}\n{${3}\n\treturn nil;\n}"
" Sub-method (Call super)
exe "Snipp sm - (${1:id})${2:method}\n{\n\t[super $2];${3}\n\treturn self;\n}"
" Method: Initialize
exe "Snipp I + (void) initialize\n{\n\t[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWIthObjectsAndKeys:\n\t\t${1}@\"value\", @\"key\",\n\t\tnil]];\n}"
" Accessor Methods For:
" Object
exe "Snipp objacc - (${1:id})${2:thing}\n{\n\treturn $2;\n}\n\n- (void) set$2:($1)\n{\n\t$1 old$2 = $2;\n\t$2 = [aValue retain];\n\t[old$2 release];\n}"
exe "Snipp forarray unsigned int\t${1:object}Count = [${2:array} count];\n\nfor (unsigned int index = 0; index < $1Count; index++)\n{\n\t${3:id}\t$1 = [$2 $1AtIndex:index];\n\t${4}\n}"
" IBOutlet
" @property (Objective-C 2.0)
exe "Snipp prop @property (${1:retain}) ${2:NSSomeClass} *${3:$2};${4}"
" @synthesize (Objective-C 2.0)
exe "Snipp syn @synthesize ${1:NSSomeClass};${2}"
" [[ alloc] init]
exe 'Snipp alloc [[${1:foo} alloc] init]${2};${3}'
" retain
exe 'Snipp ret [${1:foo} retain];${2}'
" release
exe 'Snipp rel [${1:foo} release];${2}'
