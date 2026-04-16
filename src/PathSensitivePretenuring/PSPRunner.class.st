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

{ #category : 'private' }
PSPRunner >> jsonFileName [
    ^ 'jit-measurements' , (Random new nextIntegerBetween: 1 and: 1000000) asString , '.json'
]

{ #category : 'running' }
PSPRunner >> pretenurePaths [
    | senders |
    senders := self sendersToPretenure.

    5 timesRepeat: [ Smalltalk garbageCollect ].

    self rewriteAllocationSitesWith: senders.

    10 timesRepeat: [ Smalltalk garbageCollect ]
]

{ #category : 'private' }
PSPRunner >> recordBaselineJitMetrics [
    methodsJitCompiled := self currentMethodsJitCompiled.
    blocksJitCompiled := self currentBlocksJitCompiled.
    jitCompilationTime := self currentJitCompilationTime.
    jitBlockCompilationTime := self currentJitBlockCompilationTime
]

{ #category : 'private' }
PSPRunner >> rewriteAllocationSitesWith: senders [
    PathSensitvePretenuringExperiment new
        sendersToPretenure: senders;
        rewriteAllocationSites
]

{ #category : 'running' }
PSPRunner >> run [
    | initialTime finalTime |
    self recordBaselineJitMetrics.

    initialTime := Time millisecondClockValue.
    benchmarkClass new run.
    finalTime := Time millisecondClockValue.

    self recordDeltas.
    self writeJitMeasurements.

    ^ finalTime - initialTime
]

{ #category : 'private' }
PSPRunner >> recordDeltas [
    methodsJitCompiled := self currentMethodsJitCompiled - methodsJitCompiled.
    blocksJitCompiled := self currentBlocksJitCompiled - blocksJitCompiled.
    jitCompilationTime := self currentJitCompilationTime - jitCompilationTime.
    jitBlockCompilationTime := self currentJitBlockCompilationTime - jitBlockCompilationTime
]

{ #category : 'private' }
PSPRunner >> sendersToPretenure [
    | profiler experiment |
    profiler := FiLiP new
                    profileOn: [ benchmarkClass new run ];
                    yourself.

    experiment := PathSensitvePretenuringExperiment
                      onProfiler: profiler
                      traversalStrategy: strategy.
    ^ experiment analyzeAllocations; sendersToPretenure
]

{ #category : 'api' }
PSPRunner >> strategy: aStrategy [
    strategy := aStrategy
]

{ #category : 'private' }
PSPRunner >> currentMethodsJitCompiled [
    ^ Smalltalk vm parameterAt: 75
]

{ #category : 'private' }
PSPRunner >> currentBlocksJitCompiled [
    ^ Smalltalk vm parameterAt: 77
]

{ #category : 'private' }
PSPRunner >> currentJitCompilationTime [
    ^ Smalltalk vm parameterAt: 76
]

{ #category : 'private' }
PSPRunner >> currentJitBlockCompilationTime [
    ^ Smalltalk vm parameterAt: 78
]

{ #category : 'private' }
PSPRunner >> writeJitMeasurements [
    self storeTotalMetrics.
    self writeJsonFile: self jitMetricsAsDictionary
]

{ #category : 'private' }
PSPRunner >> storeTotalMetrics [
    totalMethodsJitCompiled := self currentMethodsJitCompiled.
    totalBlocksJitCompiled := self currentBlocksJitCompiled.
    totalJitCompilationTime := self currentJitCompilationTime.
    totalJitBlockCompilationTime := self currentJitBlockCompilationTime
]

{ #category : 'private' }
PSPRunner >> writeJsonFile: aDictionary [
    | writeStream |
    writeStream := self jsonFileName asFileReference writeStream.
    [ writeStream nextPutAll: (NeoJSONWriter toStringPretty: aDictionary) ]
        ensure: [ writeStream close ]
]

{ #category : 'private' }
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
