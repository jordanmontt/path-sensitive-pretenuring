Extension { #name : 'AllocationGraph' }

{ #category : '*PathSensitivePretenuring' }
AllocationGraph >> traverseLongLivedAllocationStack: allocationStack using: aStrategy [

    | depth currentCallStack theCurrentNode |
    depth := 0.
    currentCallStack := OrderedCollection new.

    "The first one is the allocator method"
    allocationStack asMethodWithOffsetCollection allButFirstDo: [ :methodWithOffset |
        | theEdge |
        depth > 20 ifTrue: [ ^ self ].

        theCurrentNode := self nodeFor: methodWithOffset method.
        [ theEdge := theCurrentNode edgeForOffset: methodWithOffset offset ] on: NotFound do: [ :ex | ^ self ].
        currentCallStack add: theEdge.
        (aStrategy isAllocationSite: theCurrentNode fromAllocationPath: currentCallStack) ifTrue: [
            theCurrentNode
                beAllocationSite;
                appendCallStack: currentCallStack.
            ^ self ].
        depth := depth + 1 ]
]

{ #category : '*PathSensitivePretenuring' }
AllocationGraph >> traverseLongLivedSenderChainsUsing: aStrategy [

    self leaves do: [ :leaf |
        leaf allocatedObjectTypes do: [ :type |
            | callStacksOfType |
            callStacksOfType := leaf allocatedSamples collect: [ :sample | sample sendersCallStack ] as: Set.
            callStacksOfType do: [ :callStackOfType | 
                self traverseLongLivedAllocationStack: callStackOfType using: aStrategy ] ] ]
]
