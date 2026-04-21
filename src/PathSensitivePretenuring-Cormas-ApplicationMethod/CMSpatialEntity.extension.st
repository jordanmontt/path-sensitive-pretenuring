Extension { #name : 'CMSpatialEntity' }

{ #category : '*PathSensitivePretenuring-Cormas-ApplicationMethod' }
CMSpatialEntity >> addOccupant: anObject [

	(self theOccupants
		 _pretenured_382025755_at: anObject class name
		 ifAbsentPut: [ OrderedCollection new ]) add: anObject
]

{ #category : '*PathSensitivePretenuring-Cormas-ApplicationMethod' }
CMSpatialEntity >> theOccupants [

	^ theOccupants ifNil: [ theOccupants := Dictionary newTenured ]
]
