Class {
	#name : 'TextualLocationOfNewPretenuringStrategy',
	#superclass : 'AbstractPretenuringStrategy',
	#category : 'PathSensitivePretenuring-Pretenuring-Graph-Traversal',
	#package : 'PathSensitivePretenuring',
	#tag : 'Pretenuring-Graph-Traversal'
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
        and: [ self hasOnlyLongLivedEdges: anAllocationGraphNode ]
]

{ #category : 'api' }
TextualLocationOfNewPretenuringStrategy >> setUpForGraph: allocationGraph [

    | textualAllocationMethods samples |
    samples := allocationGraph samples.
    textualAllocationMethods := samples collect: #textualAllocatorMethod as: Set.
    textualAllocationMethods do: [ :aMethod | (allocationGraph nodeFor: aMethod) beTextualAllocationSite ]
]
