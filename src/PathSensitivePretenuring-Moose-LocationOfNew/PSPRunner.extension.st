Extension { #name : 'PSPRunner' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
PSPRunner >> pretenurePaths [

	| profiler |
	profiler := FiLiP new
		            profileOn: [ benchmarkClass newTenured run ];
		            yourself.

	experiment := PathSensitvePretenuringExperiment
		              onProfiler: profiler
		              traversalStrategy: strategy.
	experiment methodProtocol: protocol.
	experiment analyzeAllocations.

	experiment compilePretenuredMethods
]
