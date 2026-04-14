Class {
	#name : 'PSPRunner',
	#superclass : 'Object',
	#instVars : [
		'strategy',
		'benchmarkClass',
		'jitCompiledMethod',
		'jitCompiledMethodSeconds',
		'jitCompiledBlock',
		'jitCompilingBlockSeconds'
	],
	#category : 'PathSensitivePretenuring-Experiment',
	#package : 'PathSensitivePretenuring',
	#tag : 'Experiment'
}

{ #category : 'api - accessing' }
PSPRunner >> benchmarkClass: aClass [

    benchmarkClass := aClass
]

{ #category : 'private' }
PSPRunner >> getSendersToPretenure [

    | profiler experiment |
    profiler := FiLiP new
                    profileOn: [ benchmarkClass new run ];
                    yourself.

    experiment := PathSensitvePretenuringExperiment onProfiler: profiler traversalStrategy: strategy.
    experiment analyzeAllocations.
    ^ experiment sendersToPretenure
]

{ #category : 'running' }
PSPRunner >> pretenurePaths [

    | sendersToPretenure |
    sendersToPretenure := self getSendersToPretenure.

    5 timesRepeat: [ Smalltalk garbageCollect ].

    PathSensitvePretenuringExperiment new
        sendersToPretenure: sendersToPretenure;
        rewriteAllocationSites.

    sendersToPretenure := nil.

    10 timesRepeat: [ Smalltalk garbageCollect ]
]

{ #category : 'running' }
PSPRunner >> run [

    | initialTime finalTime |
    jitCompiledMethod := Smalltalk vm parameterAt: 75.
    jitCompiledMethodSeconds := Smalltalk vm parameterAt: 76.
    jitCompiledBlock := Smalltalk vm parameterAt: 77.
    jitCompilingBlockSeconds := Smalltalk vm parameterAt: 78.

    initialTime := Time millisecondClockValue.
    benchmarkClass new run.
    finalTime := Time millisecondClockValue.

    self writeJitMeasurements.
    ^ finalTime - initialTime
]

{ #category : 'api - accessing' }
PSPRunner >> strategy: aStrategy [

    strategy := aStrategy
]

{ #category : 'private' }
PSPRunner >> writeJitMeasurements [

    | writeStream jsonString tempDict |
    tempDict := Dictionary newFrom: {
            ('jitCompiledMethod' -> jitCompiledMethod).
            ('jitCompiledMethodSeconds' -> jitCompiledMethodSeconds).
            ('jitCompiledBlock' -> jitCompiledBlock).
            ('jitCompilingBlockSeconds' -> jitCompilingBlockSeconds) }.
    writeStream := 'jit-measurements.json' asFileReference createFile writeStream.

    jsonString := NeoJSONWriter toStringPretty: tempDict.

    writeStream nextPutAll: jsonString.
    writeStream close
]
