Extension { #name : 'AllocationGraph' }

{ #category : '*PathSensitivePretenuring' }
AllocationGraph >> traverseLongLivedAllocationStack: rawAllocationStack using: aStrategy [

    | depth currentCallStack theCurrentNode |
    depth := 0.
    currentCallStack := OrderedCollection new.

    "The first one is the allocator method"
    (rawAllocationStack allButFirst: 2) pairsDo: [ :method :offset |
        | theEdge |
        depth > 20 ifTrue: [ ^ self ].

        theCurrentNode := self nodeFor: method.
        [ theEdge := theCurrentNode edgeForOffset: offset ] on: NotFound do: [ :ex | ^ self ].
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
            | callStacksPerType |
            callStacksPerType := leaf allocatedSamples collect: [ :sample | sample rawSendersCallStack ] as: Set.
            callStacksPerType do: [ :rawCallStackOfType | 
                self traverseLongLivedAllocationStack: rawCallStackOfType using: aStrategy ] ] ]
]
