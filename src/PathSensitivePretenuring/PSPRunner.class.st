Class {
	#name : 'PSPRunner',
	#superclass : 'Object',
	#instVars : [
		'strategy',
		'benchmarkClass',
		'methodsJitCompiled',
		'blocksJitCompiled',
		'jitCompilationTime',
		'jitBlockCompilationTime',
		'totalMethodsJitCompiled',
		'totalBlocksJitCompiled',
		'totalJitCompilationTime',
		'totalJitBlockCompilationTime'
	],
	#category : 'PathSensitivePretenuring-Experiment',
	#package : 'PathSensitivePretenuring',
	#tag : 'Experiment'
}

{ #category : 'api' }
PSPRunner >> benchmarkClass: aClass [
    benchmarkClass := aClass
]

{ #category : 'accessing - vm measurements' }
PSPRunner >> currentBlocksJitCompiled [
    ^ Smalltalk vm parameterAt: 77
]

{ #category : 'accessing - vm measurements' }
PSPRunner >> currentJitBlockCompilationTime [
    ^ Smalltalk vm parameterAt: 78
]

{ #category : 'accessing - vm measurements' }
PSPRunner >> currentJitCompilationTime [
    ^ Smalltalk vm parameterAt: 76
]

{ #category : 'accessing - vm measurements' }
PSPRunner >> currentMethodsJitCompiled [
    ^ Smalltalk vm parameterAt: 75
]

{ #category : 'writing' }
PSPRunner >> jitMetricsAsDictionary [
    ^ Dictionary newFrom: {
            #methodsJitCompiled -> methodsJitCompiled.
            #jitCompilationTime -> jitCompilationTime.
            #blocksJitCompiled -> blocksJitCompiled.
            #jitBlockCompilationTime -> jitBlockCompilationTime.

            #totalMethodsJitCompiled -> totalMethodsJitCompiled.
            #totalJitCompilationTime -> totalJitCompilationTime.
            #totalBlocksJitCompiled -> totalBlocksJitCompiled.
            #totalJitBlockCompilationTime -> totalJitBlockCompilationTime }
]

{ #category : 'api' }
PSPRunner >> pretenurePaths [
    | senders |
    senders := self sendersToPretenure.

    5 timesRepeat: [ Smalltalk garbageCollect ].

    self rewriteAllocationSitesWith: senders.

    10 timesRepeat: [ Smalltalk garbageCollect ]
]

{ #category : 'jit measurements' }
PSPRunner >> recordBaselineJitMetrics [

    methodsJitCompiled := self currentMethodsJitCompiled.
    blocksJitCompiled := self currentBlocksJitCompiled.
    jitCompilationTime := self currentJitCompilationTime.
    jitBlockCompilationTime := self currentJitBlockCompilationTime
]

{ #category : 'jit measurements' }
PSPRunner >> recordDeltasJitMetrics [

    methodsJitCompiled := self currentMethodsJitCompiled - methodsJitCompiled.
    blocksJitCompiled := self currentBlocksJitCompiled - blocksJitCompiled.
    jitCompilationTime := self currentJitCompilationTime - jitCompilationTime.
    jitBlockCompilationTime := self currentJitBlockCompilationTime - jitBlockCompilationTime
]

{ #category : 'jit measurements' }
PSPRunner >> recordTotalJitMetrics [

    totalMethodsJitCompiled := self currentMethodsJitCompiled.
    totalBlocksJitCompiled := self currentBlocksJitCompiled.
    totalJitCompilationTime := self currentJitCompilationTime.
    totalJitBlockCompilationTime := self currentJitBlockCompilationTime
]

{ #category : 'running' }
PSPRunner >> rewriteAllocationSitesWith: senders [

    PathSensitvePretenuringExperiment new
        sendersToPretenure: senders;
        rewriteAllocationSites
]

{ #category : 'api' }
PSPRunner >> run [
    | initialTime finalTime |
    self recordBaselineJitMetrics.

    initialTime := Time millisecondClockValue.
    benchmarkClass new run.
    finalTime := Time millisecondClockValue.

    self recordDeltasJitMetrics.
    self recordTotalJitMetrics.
    
    self writeJitMeasurements.

    ^ finalTime - initialTime
]

{ #category : 'running' }
PSPRunner >> sendersToPretenure [

    | profiler experiment |
    profiler := FiLiP new
        profileOn: [ benchmarkClass new run ];
        yourself.

    experiment := PathSensitvePretenuringExperiment onProfiler: profiler traversalStrategy: strategy.
    experiment analyzeAllocations.
    ^ experiment sendersToPretenure
]

{ #category : 'api' }
PSPRunner >> strategy: aStrategy [
    strategy := aStrategy
]

{ #category : 'writing' }
PSPRunner >> writeJitMeasurements [

    | writeStream tempDict jsonFileName |
    tempDict := self jitMetricsAsDictionary.
    jsonFileName := 'jit-measurements' , (Random new nextIntegerBetween: 1 and: 1000000) asString , '.json'.

    writeStream := (FileLocator imageDirectory / jsonFileName) asFileReference writeStream.
    [ writeStream nextPutAll: (NeoJSONWriter toStringPretty: tempDict) ]
        ensure: [ writeStream close ]
]
