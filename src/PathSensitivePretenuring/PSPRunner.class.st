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
		'totalJitBlockCompilationTime',
		'experiment',
		'protocol'
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

{ #category : 'initialization' }
PSPRunner >> initialize [

	super initialize.
	protocol := 'automatically-generated'
]

{ #category : 'api' }
PSPRunner >> installPretenuredMethods [

    experiment installPretenuredMethods
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
PSPRunner >> methodProtocol: aString [

	protocol := aString
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
