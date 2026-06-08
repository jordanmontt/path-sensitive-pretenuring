Class {
	#name : 'TextualLocationOfNewPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
}

{ #category : 'class initialization' }
TextualLocationOfNewPretenuringStrategy class >> fileName [

   ^ 'textual'
]

{ #category : 'api' }
TextualLocationOfNewPretenuringStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: allocationStack [

	| called condition |
	condition := false.
	called := allocationStack last targetNode method.
	called isCompiledMethod ifTrue: [ | selector | 
		selector := called selector.
		((selector = #new:) | (selector = #new)) ifTrue: [ condition := true ] ].

	 condition := condition | anAllocationGraphNode isTextualAllocationSite.
	^ condition and: [ allocationStack last isLongLived ]
]

{ #category : 'api' }
TextualLocationOfNewPretenuringStrategy >> setUpForGraph: allocationGraph [

    | textualAllocationMethods samples |
    samples := allocationGraph samples.
    textualAllocationMethods := samples collect: #textualAllocatorMethod as: Set.
    textualAllocationMethods do: [ :aMethod | (allocationGraph nodeFor: aMethod) beTextualAllocationSite ]
]
