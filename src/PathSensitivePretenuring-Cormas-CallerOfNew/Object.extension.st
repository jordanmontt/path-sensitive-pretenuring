Extension { #name : 'Object' }

{ #category : '*PathSensitivePretenuring-Cormas-CallerOfNew' }
Object >> -> anObject [
	"Answer an Association between self and anObject"

	"The following example creates an association whose key is number 1 and value string 'one'."

	"(1 -> 'one') key >>> 1"

	"(1 -> 'one') value >>> 'one'"

	"Note that key and value can be ANY object."

	^ Association _pretenured_342092926_key: self value: anObject
]
