Extension { #name : 'SmallDictionary' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
SmallDictionary >> initialize [

	super initialize.
	keys := Array newTenured: 2.
	values := Array newTenured: 2.
	size := 0
]
