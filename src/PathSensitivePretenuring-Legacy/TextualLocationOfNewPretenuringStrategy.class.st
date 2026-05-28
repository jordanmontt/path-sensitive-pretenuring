Class {
	#name : 'TextualLocationOfNewPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Legacy-Graph-Traversal',
	#package : 'PathSensitivePretenuring-Legacy',
	#tag : 'Graph-Traversal'
}

{ #category : 'initialization' }
TextualLocationOfNewPretenuringStrategy class >> setUpForGraph: allocationGarph [

    ^ self new
          setUpForGraph: allocationGarph;
          yourself
]

{ #category : 'api' }
TextualLocationOfNewPretenuringStrategy >> isAllocationSite: anAllocationGraphNode fromAllocationPath: aListOfEdges [

    ^ anAllocationGraphNode isTextualAllocationSite
        and: [ self hasOnlyLongLivedEdges: aListOfEdges ]
]

{ #category : 'api' }
TextualLocationOfNewPretenuringStrategy >> setUpForGraph: allocationGraph [

    | textualAllocationMethods samples |
    samples := allocationGraph samples.
    textualAllocationMethods := samples collect: #textualAllocatorMethod as: Set.
    textualAllocationMethods do: [ :aMethod | (allocationGraph nodeFor: aMethod) beTextualAllocationSite ]
]
