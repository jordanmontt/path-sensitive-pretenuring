"
I build the bag-of-stacks dictionary from a collection of FiLiPEphemeron samples.

I replace AllocationGraph >> setUpForSamples: for the bag-of-stacks pipeline. I never merge two samples whose call stacks differ. Identical samples (same IllSendersCallStack AND same allocated type) land in the same PSPStackBag; everything else lands in its own bag.

I am intentionally trivial: one pass over the samples, one bag lookup per sample, no recursion. The whole reason for switching from the graph to bags is to make this step impossible to over-merge.
"
Class {
	#name : 'PSPStackBagBuilder',
	#superclass : 'Object',
	#instVars : [
		'bags',
		'droppedSamplesCount'
	],
	#category : 'PathSensitivePretenuring-BagOfStacks-Bag',
	#package : 'PathSensitivePretenuring-BagOfStacks',
	#tag : 'Bag'
}

{ #category : 'instance creation' }
PSPStackBagBuilder class >> onSamples: aCollection [

	^ self new
		  setUpForSamples: aCollection;
		  yourself
]

{ #category : 'api' }
PSPStackBagBuilder >> bags [
	"The collection of PSPStackBag produced from the input samples. Order is
	insertion-order of the first sample that created each bag."

	^ bags values
]

{ #category : 'accessing' }
PSPStackBagBuilder >> droppedSamplesCount [
	"How many input samples were skipped because they had no usable call stack."

	^ droppedSamplesCount
]

{ #category : 'initialization' }
PSPStackBagBuilder >> initialize [

	super initialize.
	bags := Dictionary new.
	droppedSamplesCount := 0
]

{ #category : 'private' }
PSPStackBagBuilder >> recordSample: aFiLiPEphemeron [

	| key bag stack |
	stack := aFiLiPEphemeron sendersCallStack.
	"Skip samples without a call stack. FiLiP can in principle attach a nil/empty stack;
	such samples cannot be assigned a calling context and are therefore not pretenurable
	under this pipeline."
	(stack isNil or: [ stack senders isEmpty ]) ifTrue: [
		droppedSamplesCount := droppedSamplesCount + 1.
		^ self ].

	key := Array with: stack with: aFiLiPEphemeron allocatedObjectClass.
	bag := bags
		       at: key
		       ifAbsentPut: [
			       PSPStackBag
				       forStack: stack
				       type: aFiLiPEphemeron allocatedObjectClass ].
	bag addSample: aFiLiPEphemeron
]

{ #category : 'api' }
PSPStackBagBuilder >> setUpForSamples: aCollection [

	aCollection do: [ :sample | self recordSample: sample ].
	droppedSamplesCount > 0 ifTrue: [
		('PSPStackBagBuilder: dropped ' , droppedSamplesCount printString
		 , ' of ' , aCollection size printString
		 , ' samples (no usable call stack)') traceCr ]
]

{ #category : 'accessing' }
PSPStackBagBuilder >> size [

	^ bags size
]
