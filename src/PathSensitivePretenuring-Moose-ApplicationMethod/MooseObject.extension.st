Extension { #name : 'MooseObject' }

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
MooseObject >> attributeAt: name put: value [

	| aName |
	aName := name asSymbol.
	1 to: entityAttributes size do: [ :n |
			aName == (entityAttributes at: n) key ifTrue: [
				^ ((entityAttributes at: n) value: value) value ] ].
	entityAttributes := entityAttributes _pretenured_29276380_copyWith:
		                    aName -> value.
	^ entityAttributes last value
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
MooseObject >> flush [

	cache initialize
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
MooseObject >> resetPrivateState [

	entityAttributes := #(  ).
	cache := SmallDictionary newTenured
]
