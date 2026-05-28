"
Tests for PSPStackBag itself: chain extraction order, equality, and the classification tag.
"
Class {
	#name : 'PSPStackBagTest',
	#superclass : 'TestCase',
	#category : 'PathSensitivePretenuring-BagOfStacks-Tests',
	#package : 'PathSensitivePretenuring-BagOfStacks-Tests'
}

{ #category : 'tests' }
PSPStackBagTest >> testBagsWithSameKeyAreEqual [

	| stack a b |
	stack := IllSendersCallStack senders: {
			         (Object >> #yourself). 0.
			         (Object >> #printOn:). 4 }.
	a := PSPStackBag forStack: stack type: Array.
	b := PSPStackBag forStack: stack type: Array.

	self assert: a equals: b.
	self assert: a hash equals: b hash
]

{ #category : 'tests' }
PSPStackBagTest >> testChainDropsLeafOffsetAndPreservesDepthFirstOrder [
	"Stack [m1, off1, m2, off2, m3, off3] should produce a chain
	 [(m2, off2), (m3, off3)] -- the deepest sender first, leaf offset (off1) dropped."

	| m1 m2 m3 stack bag chain |
	m1 := Object >> #yourself.
	m2 := Object >> #printOn:.
	m3 := Collection >> #species.
	stack := IllSendersCallStack senders: { m1. 11. m2. 22. m3. 33 }.

	bag := PSPStackBag forStack: stack type: Array.
	chain := bag chain.

	self assert: chain size equals: 2.
	self assert: chain first method equals: m2.
	self assert: chain first offset equals: 22.
	self assert: chain second method equals: m3.
	self assert: chain second offset equals: 33
]

{ #category : 'tests' }
PSPStackBagTest >> testClassificationTags [

	| bag |
	bag := PSPStackBag forStack: (IllSendersCallStack senders: #(  )) type: Array.

	self assert: bag classification isNil.
	self deny: bag isLongOrImmortal.

	bag beShortLived.
	self assert: bag classification equals: #short.
	self assert: bag isShortLived.
	self deny: bag isLongOrImmortal.

	bag beLongLived.
	self assert: bag classification equals: #long.
	self assert: bag isLongOrImmortal.

	bag beImmortal.
	self assert: bag classification equals: #immortal.
	self assert: bag isLongOrImmortal
]
