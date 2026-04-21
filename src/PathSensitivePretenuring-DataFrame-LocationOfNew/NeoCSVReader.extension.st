Extension { #name : 'NeoCSVReader' }

{ #category : '*PathSensitivePretenuring-DataFrame-LocationOfNew' }
NeoCSVReader >> recordClassNew: size [

	^ recordClass newTenured: size
]
