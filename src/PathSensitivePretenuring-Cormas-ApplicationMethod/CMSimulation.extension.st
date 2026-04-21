Extension { #name : 'CMSimulation' }

{ #category : '*PathSensitivePretenuring-Cormas-ApplicationMethod' }
CMSimulation >> recordData [

	data add: (self activeProbes collect: [ :probe |
			 probe name _pretenured_858844328_zyIsf: probe value ])
			asDictionary
]
