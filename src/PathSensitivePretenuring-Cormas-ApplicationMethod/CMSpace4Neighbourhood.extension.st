Extension { #name : 'CMSpace4Neighbourhood' }

{ #category : '*PathSensitivePretenuring-Cormas-ApplicationMethod' }
CMSpace4Neighbourhood >> initializeOrderedNeighbourhood: k [

	| v i |
	v := Array newTenured: 4.
	(i := self northCell: k) > 0 ifTrue: [
		v at: 1 put: (self elementaryEntitiesAt: i) ].
	(i := self westCell: k) > 0 ifTrue: [
		v at: 2 put: (self elementaryEntitiesAt: i) ].
	(i := self southCell: k) > 0 ifTrue: [
		v at: 3 put: (self elementaryEntitiesAt: i) ].
	(i := self eastCell: k) > 0 ifTrue: [
		v at: 4 put: (self elementaryEntitiesAt: i) ].
	^ (self elementaryEntitiesAt: k) neighbourhoodWithNils: v
]
