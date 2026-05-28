"
Tests for the bag-of-stacks pipeline: bag identity, chain extraction, and the two strategies' trim rules.

The most important assertion is the negative one - two samples that share a suffix but differ at the entry point land in different bags. That property is the whole reason the graph was replaced.
"
Class {
	#name : 'BagOfStacksTest',
	#superclass : 'TestCase',
	#category : 'PathSensitivePretenuring-Tests',
	#package : 'PathSensitivePretenuring-Tests'
}

{ #category : 'helpers' }
BagOfStacksTest >> mockSampleStack: aFlatMethodsAndOffsets type: aClass [

	^ MockedEphemeron new
		  sendersCallStack: (IllSendersCallStack senders: aFlatMethodsAndOffsets);
		  allocatedObjectClass: aClass;
		  textualAllocatorMethod: aFlatMethodsAndOffsets first;
		  initializationTime: 0;
		  finalizationTime: 100;
		  sizeInBytes: 16;
		  yourself
]

{ #category : 'tests' }
BagOfStacksTest >> testApplicationMethodStrategyTrimsAtFirstAppFrame [

	| basicNew nonAppFrame appFrame bag path strategy result |
	basicNew := Behavior >> #basicNew.
	nonAppFrame := Object >> #yourself.
	appFrame := Collection >> #copyWith:.

	bag := AllocationSiteBin
		       forStack: (IllSendersCallStack senders: { basicNew. 0. nonAppFrame. 4. appFrame. 8 })
		       type: Array.
	bag addSample: (self mockSampleStack: { appFrame. 0 } type: Array).
	path := bag path.

	strategy := ApplicationMethodPretenuringStrategy new
		            setUpForApplicationPackages: { appFrame package };
		            yourself.

	result := strategy trimAllocationPath: path forBag: bag.

	self assert: result size equals: 2.
	self assert: result first method equals: nonAppFrame.
	self assert: result second method equals: appFrame
]

{ #category : 'tests' }
BagOfStacksTest >> testBagsWithSameKeyAreEqual [

	| stack a b |
	stack := IllSendersCallStack senders: {
			         Behavior >> #basicNew. 0.
			         (Object >> #printOn:). 4 }.
	a := AllocationSiteBin forStack: stack type: Array.
	b := AllocationSiteBin forStack: stack type: Array.

	self assert: a equals: b.
	self assert: a hash equals: b hash
]

{ #category : 'tests' }
BagOfStacksTest >> testChainDropsLeafOffsetAndPreservesDepthFirstOrder [

	| allocatorPrimitive m2 m3 stack bag chain |
	allocatorPrimitive := Behavior >> #basicNew.
	m2 := Object >> #printOn:.
	m3 := Collection >> #copyWith:.
	stack := IllSendersCallStack senders: { allocatorPrimitive. 11. m2. 22. m3. 33 }.

	bag := AllocationSiteBin forStack: stack type: Array.
	chain := bag path.

	self assert: chain size equals: 2.
	self assert: chain first method equals: m2.
	self assert: chain first offset equals: 22.
	self assert: chain second method equals: m3.
	self assert: chain second offset equals: 33
]

{ #category : 'tests' }
BagOfStacksTest >> testClassifierKeepsDistinctPrefixesSeparate [

	| leaf shared a b sampleA sampleB classifier |
	leaf := Behavior >> #basicNew.
	shared := Object >> #printOn:.
	a := Collection >> #copyWith:.
	b := Behavior >> #basicNew.

	sampleA := self mockSampleStack: { leaf. 0. shared. 4. a. 8 } type: Array.
	sampleB := self mockSampleStack: { leaf. 0. shared. 4. b. 8 } type: Array.

	classifier := MerlinPretenuringAdviceAlgorithm new
		              setUpForSamples: { sampleA. sampleB };
		              yourself.

	self assert: classifier groupedAllocationSites size equals: 2
]

{ #category : 'tests' }
BagOfStacksTest >> testClassifierKeepsDistinctTypesSeparate [

	| leaf shared sampleA sampleB classifier |
	leaf := Behavior >> #basicNew.
	shared := Object >> #printOn:.

	sampleA := self mockSampleStack: { leaf. 0. shared. 4 } type: Array.
	sampleB := self mockSampleStack: { leaf. 0. shared. 4 } type: OrderedCollection.

	classifier := MerlinPretenuringAdviceAlgorithm new
		              setUpForSamples: { sampleA. sampleB };
		              yourself.

	self assert: classifier groupedAllocationSites size equals: 2
]

{ #category : 'tests' }
BagOfStacksTest >> testClassifierMergesIdenticalSamples [

	| leaf shared sampleA sampleB classifier bag |
	leaf := Object >> #yourself.
	shared := Object >> #printOn:.

	sampleA := self mockSampleStack: { leaf. 0. shared. 4 } type: Array.
	sampleB := self mockSampleStack: { leaf. 0. shared. 4 } type: Array.

	classifier := MerlinPretenuringAdviceAlgorithm new
		              setUpForSamples: { sampleA. sampleB };
		              yourself.

	self assert: classifier groupedAllocationSites size equals: 1.
	bag := classifier groupedAllocationSites values first.
	self assert: bag samples size equals: 2
]

{ #category : 'tests' }
BagOfStacksTest >> testTextualLocationOfNewStrategyTrimsAtTextualAllocator [

	| basicNew ocNew asoc generateReport bag chain strategy result |
	basicNew := Behavior >> #basicNew.
	ocNew := Object >> #yourself.
	asoc := Object >> #printOn:.
	generateReport := Collection >> #copyWith:.

	bag := AllocationSiteBin
		       forStack: (IllSendersCallStack senders:
				        { basicNew. 0. ocNew. 4. asoc. 8. generateReport. 12 })
		       type: Array.
	bag addSample: (self mockSampleStack: { asoc. 0 } type: Array).
	chain := bag path.

	strategy := TextualLocationOfNewPretenuringStrategy new.
	result := strategy trimAllocationPath: chain forBag: bag.

	self assert: result size equals: 2.
	self assert: result first method equals: ocNew.
	self assert: result second method equals: asoc
]
