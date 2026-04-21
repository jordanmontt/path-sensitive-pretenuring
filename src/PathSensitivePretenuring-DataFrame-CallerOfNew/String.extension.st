Extension { #name : 'String' }

{ #category : '*PathSensitivePretenuring-DataFrame-CallerOfNew' }
String class >> newTenured: sizeRequested [
	"Return a new instance with the number of indexable variables specified by the argument."

	^ self == String
		  ifTrue: [ ByteString new: sizeRequested ]
		  ifFalse: [ self basicNewTenured: sizeRequested ]
]
