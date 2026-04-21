Extension { #name : 'OrderedDictionary' }

{ #category : '*PathSensitivePretenuring-Microdown-CallerOfNew' }
OrderedDictionary >> at: aKey put: aValue [

	^ self
		  value: [ dictionary _pretenured_167547469_at: aKey put: aValue ]
		  registeringAtOrderedKeys: aKey
]
