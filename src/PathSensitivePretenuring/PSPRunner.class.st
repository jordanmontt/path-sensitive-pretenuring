Class {
	#name : 'PSPRunner',
	#superclass : 'Object',
	#instVars : [
		'benchmarkClass',
		'experiment',
		'protocol',
		'jitMethodsCompilationTime',
		'fullGCTime',
		'incrementalGCTime',
		'jitCompiledMethods',
		'jitCompiledBlocks',
		'jitBlocksCompilationTime',
		'ambiguityThreshold',
		'samplingRate',
		'pretenuringStrategy'
	],
	#category : 'PathSensitivePretenuring-Experiment',
	#package : 'PathSensitivePretenuring',
	#tag : 'Experiment'
}

{ #category : 'api - accessing' }
PSPRunner >> ambiguityThreshold: aNumber [

	ambiguityThreshold := aNumber
]

{ #category : 'api - accessing' }
PSPRunner >> benchmarkClass: aClass [
    benchmarkClass := aClass
]

{ #category : 'private' }
PSPRunner >> compileAndExportPretenuredMethodsForStrategy: strategyClass [

	| fileName writeStream samplingRateAsString |
	samplingRateAsString := samplingRate = 1
		ifTrue: [ '1' ]
		ifFalse: [ samplingRate asString allButFirst allButLast copyReplaceAll: '/' with: '_' ].
						"The asString of the fraction sorrounds the fraction with parenthesis ()"

	fileName := String streamContents: [ :stream | 
		stream << benchmarkClass fileName << '-' << strategyClass fileName << '-'
				<< samplingRateAsString << '.json' ].

	writeStream := (FileLocator imageDirectory / fileName) asFileReference writeStream.

	experiment
		pretenuringStrategy: strategyClass new;
		analyzeAllocations;
		compilePretenuredMethods;
		exportPretenuredMethods: writeStream
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

{ #category : 'api -running' }
PSPRunner >> exportPretenuredMethods: aWriteStream [

    experiment exportPretenuredMethods: aWriteStream
]

{ #category : 'initialization' }
PSPRunner >> initialize [

	super initialize.
	protocol := 'automatically-generated'.
	ambiguityThreshold := 0.9.
	samplingRate := 1 / 100 "Same as FiLiP"
]

{ #category : 'api -running' }
PSPRunner >> installPretenuredMethods [

    experiment installPretenuredMethods
]

{ #category : 'api - accessing' }
PSPRunner >> methodProtocol: aString [

	protocol := aString
]

{ #category : 'api -running' }
PSPRunner >> pretenurePaths [

	self profileBenchmark.

	experiment
		pretenuringStrategy: pretenuringStrategy;
		ambiguityThreshold: ambiguityThreshold;
		analyzeAllocations;
		compilePretenuredMethods
]

{ #category : 'api -running' }
PSPRunner >> pretenurePathsForAllStrategies [

   | traversalStrategies |
   self profileBenchmark.

   traversalStrategies := { PSPPretenuringStrategy90. PSPPretenuringStrategy80. 
				PSPPretenuringStrategy70. TextualLocationOfNewPretenuringStrategy }.	

   traversalStrategies do: [ :strategyClass |
		self compileAndExportPretenuredMethodsForStrategy: strategyClass ]
]

{ #category : 'api - accessing' }
PSPRunner >> pretenuringStrategy: aStrategy [
    pretenuringStrategy := aStrategy
]

{ #category : 'private' }
PSPRunner >> profileBenchmark [

	| profiler |
	profiler := FiLiP new
		            samplingRate: samplingRate;
		            profileOn: [ benchmarkClass new run ];
		            yourself.

	experiment := PathSensitvePretenuring new
		              setUpForProfiler: profiler;
		              methodProtocol: protocol;
		              yourself
]

{ #category : 'vm measurements' }
PSPRunner >> recordBaselineVmMetrics [

    jitCompiledMethods := self currentMethodsJitCompiled.
    jitCompiledBlocks := self currentBlocksJitCompiled.
    jitMethodsCompilationTime := self currentJitCompilationTime.
    jitBlocksCompilationTime := self currentJitBlockCompilationTime.

    fullGCTime := Smalltalk vm totalFullGCTime.
    incrementalGCTime := Smalltalk vm totalIncrementalGCTime
]

{ #category : 'vm measurements' }
PSPRunner >> recordDeltasVmMetrics [

    jitCompiledMethods := self currentMethodsJitCompiled - jitCompiledMethods.
    jitCompiledBlocks := self currentBlocksJitCompiled - jitCompiledBlocks.
    jitMethodsCompilationTime := self currentJitCompilationTime - jitMethodsCompilationTime.
    jitBlocksCompilationTime := self currentJitBlockCompilationTime - jitBlocksCompilationTime.

    fullGCTime := Smalltalk vm totalFullGCTime - fullGCTime.
    incrementalGCTime := Smalltalk vm totalIncrementalGCTime - incrementalGCTime
]

{ #category : 'api -running' }
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

{ #category : 'api - accessing' }
PSPRunner >> samplingRate: aNumber [

	samplingRate := aNumber
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
