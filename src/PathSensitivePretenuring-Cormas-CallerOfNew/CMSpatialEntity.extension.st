Extension { #name : 'CMSpatialEntity' }

{ #category : '*PathSensitivePretenuring-Cormas-CallerOfNew' }
CMSpatialEntity >> theOccupants [

	^ theOccupants ifNil: [ theOccupants := Dictionary newTenured ]
]
