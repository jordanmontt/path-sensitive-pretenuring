Extension { #name : 'CMSpaceNeighbourhood' }

{ #category : '*PathSensitivePretenuring-Cormas-CallerOfNew' }
CMSpaceNeighbourhood >> initializeNeighbourhood [
	" Private - Initialize aSpaceModel neighbourhood values based on the receiver "

	1 to: self spaceModel gridSize do: [ :k |
			(self elementaryEntitiesAt: k) ifNotNil: [
				self _pretenured_469130025_initializeOrderedNeighbourhood: k ] ]
]
