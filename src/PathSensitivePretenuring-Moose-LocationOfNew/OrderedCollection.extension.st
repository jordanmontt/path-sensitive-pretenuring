Extension { #name : 'OrderedCollection' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
OrderedCollection >> growAtLast [
	"Add new empty slots to the end of array, while keeping the empty slots at the front."

	"OrderedCollection new capacity >>> 10"

	"(OrderedCollection new growAtLast; capacity) >>> 20"

	| newArray |
	newArray := self class arrayType newTenured: (array size * 2 max: 1).
	newArray
		replaceFrom: firstIndex
		to: lastIndex
		with: array
		startingAt: firstIndex.
	array := newArray
]
