Extension { #name : 'String' }

{ #category : '*PathSensitivePretenuring-Microdown-LocationOfNew' }
String class >> new: sizeRequested [
	"Return a new instance with the number of indexable variables specified by the argument."

	^ self == String
		  ifTrue: [ ByteString new: sizeRequested ]
		  ifFalse: [ self basicNewTenured: sizeRequested ]
]
