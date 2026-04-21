Extension { #name : 'Association' }

{ #category : '*PathSensitivePretenuring-DataFrame-CallerOfNew' }
Association class >> _pretenured_519253037_key: newKey value: newValue [
	"Answer an instance of me with the arguments as the key and value of
	the association."

	^ self basicNewTenured key: newKey value: newValue
]
