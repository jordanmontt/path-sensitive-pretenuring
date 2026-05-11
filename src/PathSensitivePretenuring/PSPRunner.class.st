Class {
	#name : 'PSPRunner',
	#superclass : 'Object',
	#instVars : [
		'strategy',
		'benchmarkClass',
		'experiment',
		'protocol',
		'jitMethodsCompilationTime',
		'fullGCTime',
		'incrementalGCTime',
		'jitCompiledMethods',
		'jitCompiledBlocks',
		'jitBlocksCompilationTime',
		'ambiguityThreshold'
	],
	#category : 'PathSensitivePretenuring-Experiment',
	#package : 'PathSensitivePretenuring',
	#tag : 'Experiment'
}

{ #category : 'initialization' }
PSPRunner >> ambiguityThreshold: aNumber [

	ambiguityThreshold := aNumber
]

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

{ #category : 'api' }
PSPRunner >> exportPretenuredMethods: aWriteStream [

    experiment exportPretenuredMethods: aWriteStream
]

{ #category : 'initialization' }
PSPRunner >> initialize [

	super initialize.
	protocol := 'automatically-generated'.
	ambiguityThreshold := 0.9
]

{ #category : 'api' }
PSPRunner >> installPretenuredMethods [

    experiment installPretenuredMethods
]

{ #category : 'api' }
PSPRunner >> methodProtocol: aString [

	protocol := aString
]

{ #category : 'api' }
PSPRunner >> pretenurePaths [

	| profiler |
	profiler := FiLiP new
		            profileOn: [ benchmarkClass new run ];
		            yourself.

	experiment := PathSensitvePretenuringExperiment new
							setUpForProfiler: profiler;
							allocationSiteStrategy: strategy;
							ambiguityThreshold: ambiguityThreshold;
							yourself.
	experiment methodProtocol: protocol.
	experiment analyzeAllocations.

	experiment compilePretenuredMethods
]

{ #category : 'vm measurements' }
PSPRunner >> recordBaselineVmMetrics [

    jitCompiledMethods := self currentMethodsJitCompiled.
    jitCompiledBlocks := self currentBlocksJitCompiled.
    jitMethodsCompilationTime := self currentJitCompilationTime.
    jitBlocksCompilationTime := self currentJitBlockCompilationTime.

    fullGCTime := Smalltalk vm  totalFullGCTime.
    incrementalGCTime := Smalltalk vm   totalIncrementalGCTime
]

{ #category : 'vm measurements' }
PSPRunner >> recordDeltasVmMetrics [

    jitCompiledMethods := self currentMethodsJitCompiled - jitCompiledMethods.
    jitCompiledBlocks := self currentBlocksJitCompiled - jitCompiledBlocks.
    jitMethodsCompilationTime := self currentJitCompilationTime - jitMethodsCompilationTime.
    jitBlocksCompilationTime := self currentJitBlockCompilationTime - jitBlocksCompilationTime.

    fullGCTime := Smalltalk vm  totalFullGCTime - fullGCTime.
    incrementalGCTime := Smalltalk vm   totalIncrementalGCTime - incrementalGCTime
]

{ #category : 'api' }
PSPRunner >> run [
    | initialTime finalTime |
    self recordBaselineVmMetrics.

    initialTime := Time millisecondClockValue.
    benchmarkClass new run.
    finalTime := Time millisecondClockValue.

    self recordDeltasVmMetrics.
    self writeVmMeasurements.

	"Rebench expects seconds"
    ^ ((finalTime - initialTime) / 1000) asFloat
]

{ #category : 'api' }
PSPRunner >> strategy: aStrategy [
    strategy := aStrategy
]

{ #category : 'writing' }
PSPRunner >> vmMetricsAsDictionary [

	^ Dictionary newFrom: {
			  (#jitCompiledMethods -> jitCompiledMethods).
			  (#jitMethodsCompilationTime -> jitMethodsCompilationTime).
			  (#jitCompiledBlocks -> jitCompiledBlocks).
			  (#jitBlockCompilationTime -> jitBlocksCompilationTime).

			  (#totalJitCompilationTime -> (jitMethodsCompilationTime + jitBlocksCompilationTime)).
			  (#totalJitCompiledMethods -> (jitCompiledMethods + jitCompiledBlocks)).

			  (#fullGCTime -> fullGCTime).
			  (#incrementalGCTime -> incrementalGCTime).

			  (#totalGcTime -> (fullGCTime + incrementalGCTime)) }
]

{ #category : 'writing' }
PSPRunner >> writeVmMeasurements [
	| metricsDict fileName fileReference measurements |

	metricsDict := self vmMetricsAsDictionary.
	fileName := 'jit-measurements.json'.
	fileReference := (FileLocator imageDirectory / fileName) asFileReference.

	measurements := OrderedCollection new.
	fileReference exists ifTrue: [
		measurements addAll: (NeoJSONReader fromString: fileReference contents) ].
	measurements add: metricsDict.

	fileReference writeStreamDo: [ :stream |
		stream nextPutAll: (NeoJSONWriter toStringPretty: measurements) ].
]
