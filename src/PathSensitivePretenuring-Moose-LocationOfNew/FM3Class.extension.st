Extension { #name : 'FM3Class' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
FM3Class >> createInstance [

	^ implementingClass
		  ifNil: [ FMRuntimeElement new description: self ]
		  ifNotNil: [ implementingClass newTenured ]
]
