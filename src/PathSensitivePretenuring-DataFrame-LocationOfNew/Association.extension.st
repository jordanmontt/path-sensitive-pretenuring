Extension { #name : 'Association' }

{ #category : '*PathSensitivePretenuring-DataFrame-LocationOfNew' }
Association class >> _pretenured_47731337_key: newKey value: newValue [
	"Answer an instance of me with the arguments as the key and value of
	the association."

	^ self basicNewTenured key: newKey value: newValue
]
