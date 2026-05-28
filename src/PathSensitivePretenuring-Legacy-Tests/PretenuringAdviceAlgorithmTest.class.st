"
An IllAnalyzerTest is a test class for testing the behavior of IllAnalyzer
"
Class {
	#name : 'PretenuringAdviceAlgorithmTest',
	#superclass : 'TestCase',
	#instVars : [
		'classificator'
	],
	#category : 'PathSensitivePretenuring-Legacy-Tests',
	#package : 'PathSensitivePretenuring-Legacy-Tests'
}

{ #category : 'running' }
PretenuringAdviceAlgorithmTest >> setUp [

	super setUp.

	classificator := MerlinPretenuringAdviceAlgorithm new
]

{ #category : 'tests' }
PretenuringAdviceAlgorithmTest >> testCalculateMaxLiveSize [

	| mockedAllocationGraph |
	mockedAllocationGraph := MockedClassForMaxSizeTest new.
	
	classificator
		allocationGraph: mockedAllocationGraph;
		startTime: mockedAllocationGraph initialTime;
		endTime: mockedAllocationGraph endTime.

	self assert: classificator maxLiveSize equals: 140 "j and m are the only alive objects at point 13 of the timeline. J weights 100 bytes and m 40".
]

{ #category : 'tests' }
PretenuringAdviceAlgorithmTest >> testIsObjectImmortal [

	| startTime endTime illEphe |
	startTime := 10.
	endTime := 110.
	
	classificator
		endTime: endTime;
		startTime: startTime.

	illEphe := MockedEphemeron new
		initializationTime: 30;
		finalizationTime: 70;
		yourself.
	self deny: (classificator isObjectImmortal: illEphe).
	
	illEphe := MockedEphemeron new
		initializationTime: 30;
		finalizationTime: 71;
		yourself.
	self assert: (classificator isObjectImmortal: illEphe).
	
	illEphe := MockedEphemeron new
		initializationTime: 10;
		finalizationTime: 110;
		yourself.
	self assert: (classificator isObjectImmortal: illEphe).
	
	"Strange case"
	classificator := MerlinPretenuringAdviceAlgorithm new
		startTime: 0;
		endTime: 17;
		yourself.
	illEphe := MockedEphemeron new
		initializationTime: 10;
		finalizationTime: 11;
		yourself.
	self deny: (classificator isObjectImmortal: illEphe).
]
