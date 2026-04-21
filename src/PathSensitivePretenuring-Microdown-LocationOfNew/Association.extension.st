Extension { #name : 'Association' }

{ #category : '*PathSensitivePretenuring-Microdown-LocationOfNew' }
Association class >> _pretenured_363245136_key: newKey value: newValue [
	"Answer an instance of me with the arguments as the key and value of
	the association."

	^ self basicNewTenured key: newKey value: newValue
]
