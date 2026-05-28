Class {
	#name : 'MockedClassForMaxSizeTest',
	#superclass : 'Object',
	#instVars : [
		'mockedObjectAllocations',
		'initialTime'
	],
	#category : 'PathSensitivePretenuring-Legacy-Tests',
	#package : 'PathSensitivePretenuring-Legacy-Tests'
}

{ #category : 'initialization' }
MockedClassForMaxSizeTest >> allocatedSamples [

	^ mockedObjectAllocations
]

{ #category : 'initialization' }
MockedClassForMaxSizeTest >> endTime [

	^ self allocatedSamples max: #finalizationTime
]

{ #category : 'initialization' }
MockedClassForMaxSizeTest >> initialTime [

	^ self allocatedSamples min: #initializationTime
]

{ #category : 'initialization' }
MockedClassForMaxSizeTest >> initialize [

	| a b c d e f g h i j k l m |
	super initialize.
	
	initialTime := Time primUTCMicrosecondsClock.
	a := MockedEphemeron new
		     initializationTime: initialTime + 1000000;
		     finalizationTime: initialTime + 2000000;
		     sizeInBytes: 10;
		     key: #a;
		     yourself.
	b := MockedEphemeron new
		     initializationTime: initialTime + 2000000;
		     finalizationTime: initialTime + 6000000;
		     sizeInBytes: 10;
		     key: #b;
		     yourself.
	c := MockedEphemeron new
		     initializationTime: initialTime + 4000000;
		     finalizationTime: initialTime + 9000000;
		     sizeInBytes: 10;
		     key: #c;
		     yourself.
	d := MockedEphemeron new
		     initializationTime: initialTime + 5000000;
		     finalizationTime: initialTime + 6000000;
		     sizeInBytes: 10;
		     key: #d;
		     yourself.
	e := MockedEphemeron new
		     initializationTime: initialTime + 3000000;
		     finalizationTime: initialTime + 11000000;
		     sizeInBytes: 10;
		     key: #e;
		     yourself.
	f := MockedEphemeron new
		     initializationTime: initialTime + 4000000;
		     finalizationTime: initialTime + 7000000;
		     sizeInBytes: 10;
		     key: #f;
		     yourself.
	g := MockedEphemeron new
		     initializationTime: initialTime + 5000000;
		     finalizationTime: initialTime + 6000000;
		     sizeInBytes: 10;
		     key: #g;
		     yourself.
	h := MockedEphemeron new
		     initializationTime: initialTime + 5000000;
		     finalizationTime: initialTime + 6000000;
		     sizeInBytes: 10;
		     key: #h;
		     yourself.
	i := MockedEphemeron new
		     initializationTime: initialTime + 8000000;
		     finalizationTime: initialTime + 12000000;
		     sizeInBytes: 10;
		     key: #i;
		     yourself.
	j := MockedEphemeron new
		     initializationTime: initialTime + 13000000;
		     finalizationTime: initialTime + 16000000;
		     sizeInBytes: 100;
		     key: #j;
		     yourself.
	k := MockedEphemeron new
		     initializationTime: initialTime + 14000000;
		     finalizationTime: initialTime + 16000000;
		     sizeInBytes: 10;
		     key: #k;
		     yourself.
	l := MockedEphemeron new
		     initializationTime: initialTime + 15000000;
		     finalizationTime: initialTime + 16000000;
		     sizeInBytes: 10;
		     key: #l;
		     yourself.
	m := MockedEphemeron new
		     initializationTime: initialTime + 11000000;
		     finalizationTime: initialTime + 14000000;
		     sizeInBytes: 40;
		     key: #m;
		     yourself.

	mockedObjectAllocations := { a. b. c. d. e. f. g. h. i. j. k. l. m }
			sorted: [ :v1 :v2 | v1 initializationTime < v2 initializationTime ]
]
