Class {
	#name : 'PSPRunner',
	#superclass : 'Object',
	#instVars : [
		'strategy',
		'benchmarkClass',
		'methodsJitCompiled',
		'blocksJitCompiled',
		'jitBlockCompilationTime',
		'experiment',
		'protocol',
		'jitMethodsCompilationTime',
		'gcTime'
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

{ #category : 'api' }
PSPRunner >> exportPretenuredMethods: aWriteStream [

    experiment exportPretenuredMethods: aWriteStream
]

{ #category : 'initialization' }
PSPRunner >> initialize [

	super initialize.
	protocol := 'automatically-generated'
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

	experiment := PathSensitvePretenuringExperiment
		              onProfiler: profiler
		              traversalStrategy: strategy.
	experiment methodProtocol: protocol.
	experiment analyzeAllocations.

	experiment compilePretenuredMethods
]

{ #category : 'jit measurements' }
PSPRunner >> recordBaselineVmMetrics [

    methodsJitCompiled := self currentMethodsJitCompiled.
    blocksJitCompiled := self currentBlocksJitCompiled.
    jitMethodsCompilationTime := self currentJitCompilationTime.
    jitBlockCompilationTime := self currentJitBlockCompilationTime.
    gcTime := Smalltalk vm totalGCTime.
]

{ #category : 'jit measurements' }
PSPRunner >> recordDeltasVmMetrics [

    methodsJitCompiled := self currentMethodsJitCompiled - methodsJitCompiled.
    blocksJitCompiled := self currentBlocksJitCompiled - blocksJitCompiled.
    jitMethodsCompilationTime := self currentJitCompilationTime - jitMethodsCompilationTime.
    jitBlockCompilationTime := self currentJitBlockCompilationTime - jitBlockCompilationTime.
    gcTime := Smalltalk vm totalGCTime - gcTime 
]

{ #category : 'api' }
PSPRunner >> run [
    | initialTime finalTime |
    self recordBaselineVmMetrics.

    initialTime := Time millisecondClockValue.
    benchmarkClass new run.
    finalTime := Time millisecondClockValue.

    self recordDeltasVmMetrics.
    self writeJitMeasurements.

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
			  (#methodsJitCompiled -> methodsJitCompiled).
			  (#jitMethodsCompilationTime -> jitMethodsCompilationTime).
			  (#blocksJitCompiled -> blocksJitCompiled).
			  (#jitBlockCompilationTime -> jitBlockCompilationTime).
			  (#gcTime -> gcTime) }
]

{ #category : 'writing' }
PSPRunner >> writeJitMeasurements [
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
