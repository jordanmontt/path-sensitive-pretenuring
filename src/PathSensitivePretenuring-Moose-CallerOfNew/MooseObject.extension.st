Extension { #name : 'MooseObject' }

{ #category : '*PathSensitivePretenuring-Moose-CallerOfNew' }
MooseObject >> attributeAt: name put: value [

	| aName |
	aName := name asSymbol.
	1 to: entityAttributes size do: [ :n |
			aName == (entityAttributes at: n) key ifTrue: [
				^ ((entityAttributes at: n) value: value) value ] ].
	entityAttributes := entityAttributes _pretenured_717861656_copyWith:
		                    aName -> value.
	^ entityAttributes last value
]

{ #category : '*PathSensitivePretenuring-Moose-CallerOfNew' }
MooseObject >> flush [

	cache initialize
]

{ #category : '*PathSensitivePretenuring-Moose-CallerOfNew' }
MooseObject >> resetPrivateState [

	entityAttributes := #(  ).
	cache := SmallDictionary newTenured
]
