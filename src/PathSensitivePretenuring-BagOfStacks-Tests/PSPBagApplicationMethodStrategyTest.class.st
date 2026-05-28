"
Tests for PSPBagApplicationMethodStrategy. The trim slices the chain from the deepest sender up to (and including) the first frame whose method's package is in the configured application packages.
"
Class {
	#name : 'PSPBagApplicationMethodStrategyTest',
	#superclass : 'TestCase',
	#category : 'PathSensitivePretenuring-BagOfStacks-Tests',
	#package : 'PathSensitivePretenuring-BagOfStacks-Tests'
}

{ #category : 'helpers' }
PSPBagApplicationMethodStrategyTest >> bagWithStack: aFlatArray type: aClass [

	| stack bag |
	stack := IllSendersCallStack senders: aFlatArray.
	bag := PSPStackBag forStack: stack type: aClass.
	bag addSample: (PSPBagMockEphemeron new
			 stack: aFlatArray
			 type: aClass
			 initializationTime: 0
			 finalizationTime: 1
			 sizeInBytes: 8
			 textualAllocatorMethod: aFlatArray first
			 offset: aFlatArray second;
			 yourself).
	^ bag
]

{ #category : 'tests' }
PSPBagApplicationMethodStrategyTest >> testReturnsEmptyWhenNoFrameIsInAppPackage [

	| m1 m2 m3 bag strategy result |
	m1 := Behavior >> #basicNew.
	m2 := Object >> #yourself.
	m3 := Object >> #printOn:.

	bag := self
		       bagWithStack: { m1. 0. m2. 4. m3. 8 }
		       type: Array.

	"Configure with a package that is NOT the package of m2 or m3."
	strategy := PSPBagApplicationMethodStrategy new
		            setUpForApplicationPackages: { Smalltalk globals } asSet;
		            yourself.

	result := strategy trimChain: bag chain forBag: bag.

	self assert: result isEmpty
]

{ #category : 'tests' }
PSPBagApplicationMethodStrategyTest >> testTrimStopsAtFirstAppFrame [
	"Use a real Pharo method as the 'app' frame. Configure the strategy with that method's
	 own package; expect the trim to stop at it."

	| basicNew nonAppFrame appFrame bag strategy result |
	basicNew := Behavior >> #basicNew.
	nonAppFrame := Object >> #yourself.
	appFrame := Collection >> #species.

	"Stack: basicNew (leaf), nonAppFrame, appFrame.
	 Full chain (leaf offset dropped): [(nonAppFrame, 4), (appFrame, 8)]."
	bag := self
		       bagWithStack:
		       { basicNew. 0. nonAppFrame. 4. appFrame. 8 }
		       type: Array.
	strategy := PSPBagApplicationMethodStrategy new
		            setUpForApplicationPackages: { appFrame package };
		            yourself.

	result := strategy trimChain: bag chain forBag: bag.

	self assert: result size equals: 2.
	self assert: result first method equals: nonAppFrame.
	self assert: result second method equals: appFrame
]
