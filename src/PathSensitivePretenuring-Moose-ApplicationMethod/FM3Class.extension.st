Extension { #name : 'FM3Class' }

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
FM3Class >> createInstance [

	^ implementingClass
		  ifNil: [ FMRuntimeElement new description: self ]
		  ifNotNil: [ implementingClass newTenured ]
]
