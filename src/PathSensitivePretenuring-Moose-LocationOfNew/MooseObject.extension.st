Extension { #name : 'MooseObject' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
MooseObject >> resetPrivateState [

	entityAttributes := #(  ).
	cache := SmallDictionary newTenured
]
