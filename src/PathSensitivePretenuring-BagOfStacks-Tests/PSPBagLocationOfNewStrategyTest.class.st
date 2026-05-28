"
Tests for PSPBagLocationOfNewStrategy. The trim slices the chain from the deepest sender up to (and including) the frame whose method is the bag's textualAllocatorMethod.
"
Class {
	#name : 'PSPBagLocationOfNewStrategyTest',
	#superclass : 'TestCase',
	#category : 'PathSensitivePretenuring-BagOfStacks-Tests',
	#package : 'PathSensitivePretenuring-BagOfStacks-Tests'
}

{ #category : 'helpers' }
PSPBagLocationOfNewStrategyTest >> bagWithStack: aFlatArray type: aClass textualAllocator: anAllocator [
	"Build a bag with one sample so its #textualAllocatorMethod is well-defined."

	| stack bag sample |
	stack := IllSendersCallStack senders: aFlatArray.
	bag := PSPStackBag forStack: stack type: aClass.
	sample := PSPBagMockEphemeron new
		          stack: aFlatArray
		          type: aClass
		          initializationTime: 0
		          finalizationTime: 1
		          sizeInBytes: 8
		          textualAllocatorMethod: anAllocator
		          offset: 0;
		          yourself.
	bag addSample: sample.
	^ bag
]

{ #category : 'tests' }
PSPBagLocationOfNewStrategyTest >> testReturnsEmptyWhenTextualAllocatorNotInChain [

	| basicNew metaNew bag strategy result |
	basicNew := Behavior >> #basicNew.
	metaNew := Object >> #yourself.

	"textualAllocator is set to a method that does not appear anywhere in the captured
	stack. This is the truncation-at-depth-cap case described in the strategy comment."
	bag := self
		       bagWithStack:
		       { basicNew. 0. metaNew. 4 }
		       type: Array
		       textualAllocator: Collection >> #species.
	strategy := PSPBagLocationOfNewStrategy new.

	result := strategy trimChain: bag chain forBag: bag.

	self assert: result isEmpty
]

{ #category : 'tests' }
PSPBagLocationOfNewStrategyTest >> testTrimKeepsUpToAndIncludingTextualAllocator [
	"Full stack: [basicNew, ocNew, asoc, generateReport] with asoc as the textual allocator.
	 Full chain (leaf offset dropped): [(ocNew, _), (asoc, _), (generateReport, _)].
	 Expected trim: [(ocNew, _), (asoc, _)]."

	| basicNew ocNew asoc generateReport bag strategy result |
	basicNew := Behavior >> #basicNew.
	ocNew := Object >> #yourself.
	asoc := Object >> #printOn:.
	generateReport := Collection >> #species.

	bag := self
		       bagWithStack:
		       { basicNew. 0. ocNew. 4. asoc. 8. generateReport. 12 }
		       type: Array
		       textualAllocator: asoc.
	strategy := PSPBagLocationOfNewStrategy new.

	result := strategy trimChain: bag chain forBag: bag.

	self assert: result size equals: 2.
	self assert: result first method equals: ocNew.
	self assert: result second method equals: asoc
]
