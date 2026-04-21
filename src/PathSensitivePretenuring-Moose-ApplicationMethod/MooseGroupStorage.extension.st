Extension { #name : 'MooseGroupStorage' }

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
MooseGroupStorage >> updateCacheOnAddingOf: anElement [

	(byType privateMooseStorageAt: anElement class)
		_pretenured_796327484_add: anElement.
	^ anElement
]
