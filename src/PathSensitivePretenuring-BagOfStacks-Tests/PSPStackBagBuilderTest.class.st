"
Tests for PSPStackBagBuilder. The most important assertions are the negative ones: that two samples with different call-stack prefixes do NOT merge, even when they end at the same primitive and allocate the same type. That property is the whole point of bag-of-stacks.
"
Class {
	#name : 'PSPStackBagBuilderTest',
	#superclass : 'TestCase',
	#category : 'PathSensitivePretenuring-BagOfStacks-Tests',
	#package : 'PathSensitivePretenuring-BagOfStacks-Tests'
}

{ #category : 'helpers' }
PSPStackBagBuilderTest >> mockSampleWithStack: aFlatArray type: aType [

	^ PSPBagMockEphemeron new
		  stack: aFlatArray
		  type: aType
		  initializationTime: 0
		  finalizationTime: 100
		  sizeInBytes: 16
		  textualAllocatorMethod: aFlatArray first
		  offset: aFlatArray second;
		  yourself
]

{ #category : 'tests' }
PSPStackBagBuilderTest >> testDifferentPrefixesDoNotMerge [
	"The defining property of bag-of-stacks: two samples that share a suffix but differ
	at the entry point land in different bags."

	| leaf caller entryA entryB sampleA sampleB builder |
	leaf := Object >> #yourself.
	caller := Object >> #printOn:.
	entryA := Collection >> #species.
	entryB := Behavior >> #basicNew.

	"Same leaf+caller, different entry points."
	sampleA := self
		           mockSampleWithStack:
		           { leaf. 0. caller. 4. entryA. 8 }
		           type: Array.
	sampleB := self
		           mockSampleWithStack:
		           { leaf. 0. caller. 4. entryB. 12 }
		           type: Array.

	builder := PSPStackBagBuilder onSamples: { sampleA. sampleB }.

	self assert: builder size equals: 2
]

{ #category : 'tests' }
PSPStackBagBuilderTest >> testDifferentTypesDoNotMerge [
	"Two samples with the same call stack but different allocated types land in
	different bags. The bag is keyed on (stack, type)."

	| leaf caller entry sampleA sampleB builder |
	leaf := Object >> #yourself.
	caller := Object >> #printOn:.
	entry := Collection >> #species.

	sampleA := self
		           mockSampleWithStack:
		           { leaf. 0. caller. 4. entry. 8 }
		           type: Array.
	sampleB := self
		           mockSampleWithStack:
		           { leaf. 0. caller. 4. entry. 8 }
		           type: OrderedCollection.

	builder := PSPStackBagBuilder onSamples: { sampleA. sampleB }.

	self assert: builder size equals: 2
]

{ #category : 'tests' }
PSPStackBagBuilderTest >> testEmptyStacksAreCountedAndDropped [

	| good empty builder |
	good := self
		        mockSampleWithStack: { (Object >> #yourself). 0 }
		        type: Array.
	empty := PSPBagMockEphemeron new
		         allocatedObjectClass: Array;
		         sendersCallStack: (IllSendersCallStack senders: #(  ));
		         initializationTime: 0;
		         finalizationTime: 1;
		         sizeInBytes: 16;
		         yourself.

	builder := PSPStackBagBuilder onSamples: { good. empty }.

	self assert: builder size equals: 1.
	self assert: builder droppedSamplesCount equals: 1
]

{ #category : 'tests' }
PSPStackBagBuilderTest >> testIdenticalSamplesGroupIntoOneBag [

	| leaf caller entry sampleA sampleB builder bag |
	leaf := Object >> #yourself.
	caller := Object >> #printOn:.
	entry := Collection >> #species.

	sampleA := self
		           mockSampleWithStack:
		           { leaf. 0. caller. 4. entry. 8 }
		           type: Array.
	sampleB := self
		           mockSampleWithStack:
		           { leaf. 0. caller. 4. entry. 8 }
		           type: Array.

	builder := PSPStackBagBuilder onSamples: { sampleA. sampleB }.

	self assert: builder size equals: 1.
	bag := builder bags first.
	self assert: bag samples size equals: 2
]
