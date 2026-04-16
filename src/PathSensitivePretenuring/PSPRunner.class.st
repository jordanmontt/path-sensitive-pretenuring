Class {
	#name : 'PSPRunner',
	#superclass : 'Object',
	#instVars : [
		'strategy',
		'benchmarkClass',
		'jitCompiledMethods',
		'jitCompiledBlocks',
		'timeCompilingJitMethodsMilliseconds',
		'timeCompilingJitBlocksMilliseconds'
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
PSPRunner >> getJsonName [

    ^ 'jit-measurements' , (Random new nextIntegerBetween: 1 and: 1000000) asString , '.json'
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
    jitCompiledMethods := Smalltalk vm parameterAt: 75.
    timeCompilingJitMethodsMilliseconds := Smalltalk vm parameterAt: 76.
    jitCompiledBlocks := Smalltalk vm parameterAt: 77.
    timeCompilingJitBlocksMilliseconds := Smalltalk vm parameterAt: 78.

    initialTime := Time millisecondClockValue.
    benchmarkClass new run.
    finalTime := Time millisecondClockValue.

	"the idea here is to measure the jit compilation that happened during the executiong of  benchmarkClass new run"
    jitCompiledMethods := (Smalltalk vm parameterAt: 75) - jitCompiledMethods.
    timeCompilingJitMethodsMilliseconds := (Smalltalk vm parameterAt: 76) - timeCompilingJitMethodsMilliseconds.
    jitCompiledBlocks := (Smalltalk vm parameterAt: 77) - jitCompiledBlocks.
    timeCompilingJitBlocksMilliseconds := (Smalltalk vm parameterAt: 78) - timeCompilingJitBlocksMilliseconds.

    self writeJitMeasurements.
    ^ finalTime - initialTime
]

{ #category : 'api - accessing' }
PSPRunner >> strategy: aStrategy [

    strategy := aStrategy
]

{ #category : 'private' }
PSPRunner >> writeJitMeasurements [

    | writeStream jsonString tempDict totalJitCompiledMethods totalTimeCompilingJitMethodsMilliseconds totalJitCompiledBlocks totalTimeCompilingJitBlocksMilliseconds |
    totalJitCompiledMethods := Smalltalk vm parameterAt: 75.
    totalTimeCompilingJitMethodsMilliseconds := Smalltalk vm parameterAt: 76.
    totalJitCompiledBlocks := Smalltalk vm parameterAt: 77.
    totalTimeCompilingJitBlocksMilliseconds := Smalltalk vm parameterAt: 78.

    tempDict := Dictionary newFrom: {
            ('jitCompiledMethods' -> jitCompiledMethods).
            ('timeCompilingJitMethodsMilliseconds' -> timeCompilingJitMethodsMilliseconds).
            ('jitCompiledBlocks' -> jitCompiledBlocks).
            ('timeCompilingJitBlocksMilliseconds' -> timeCompilingJitBlocksMilliseconds).

            ('totalJitCompiledMethods' -> totalJitCompiledMethods).
            ('totalTimeCompilingJitMethodsMilliseconds' -> totalTimeCompilingJitMethodsMilliseconds).
            ('totalJitCompiledBlocks' -> totalJitCompiledBlocks).
            ('totalTimeCompilingJitBlocksMilliseconds' -> totalTimeCompilingJitBlocksMilliseconds) }.
    
    writeStream := self getJsonName asFileReference createFile writeStream.
    jsonString := NeoJSONWriter toStringPretty: tempDict.

    writeStream nextPutAll: jsonString.
    writeStream close
]
