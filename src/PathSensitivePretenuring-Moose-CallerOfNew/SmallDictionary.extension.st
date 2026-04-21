Extension { #name : 'SmallDictionary' }

{ #category : '*PathSensitivePretenuring-Moose-CallerOfNew' }
SmallDictionary >> initialize [

	super initialize.
	keys := Array new: 2.
	values := Array newTenured: 2.
	size := 0
]
