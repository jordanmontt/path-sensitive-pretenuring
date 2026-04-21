Extension { #name : 'OrderedCollection' }

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_796327484_add: newObject [
	"Add a new object at the end of the collection, and returns the object itself"

	"((OrderedCollection new add: 42; yourself) add: 43; yourself) asArray >>> #(42 43)"

	"Add returns the object itself"

	"(OrderedCollection new add: 42) >>> 42"

	"You may want to use yourself to return the collection itself"

	"(OrderedCollection new add: 42; yourself) class >>> OrderedCollection"

	"(OrderedCollection new add: 42; yourself) size >>> 1"

	^ self _pretenured_796327484_addLast: newObject
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_796327484_addLast: newObject [
	"Add newObject to the end of the receiver. Answer newObject."

	lastIndex = array size ifTrue: [
		self _pretenured_796327484_makeRoomAtLast ].
	lastIndex := lastIndex + 1.
	^ array at: lastIndex put: newObject
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_796327484_growAtLast [
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

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_796327484_makeRoomAtLast [
	"Make some empty slots at the end of the array. If we have more than 50% free space, then just move the elements, so that the last 50% of the slots are free, otherwise add new free slots to the end by growing. Precondition: lastIndex = array size"

	| tally newFirstIndex newLastIndex |
	tally := self size.
	tally * 2 >= lastIndex ifTrue: [
		^ self _pretenured_796327484_growAtLast ].
	tally = 0 ifTrue: [ ^ self resetTo: 1 ].
	newLastIndex := lastIndex // 2.
	newFirstIndex := newLastIndex - lastIndex + firstIndex.
	array
		replaceFrom: newFirstIndex
		to: newLastIndex
		with: array
		startingAt: firstIndex.
	array from: newLastIndex + 1 to: lastIndex put: nil.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_86169303_add: newObject [
	"Add a new object at the end of the collection, and returns the object itself"

	"((OrderedCollection new add: 42; yourself) add: 43; yourself) asArray >>> #(42 43)"

	"Add returns the object itself"

	"(OrderedCollection new add: 42) >>> 42"

	"You may want to use yourself to return the collection itself"

	"(OrderedCollection new add: 42; yourself) class >>> OrderedCollection"

	"(OrderedCollection new add: 42; yourself) size >>> 1"

	^ self _pretenured_86169303_addLast: newObject
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_86169303_addLast: newObject [
	"Add newObject to the end of the receiver. Answer newObject."

	lastIndex = array size ifTrue: [
		self _pretenured_86169303_makeRoomAtLast ].
	lastIndex := lastIndex + 1.
	^ array at: lastIndex put: newObject
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_86169303_growAtLast [
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

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_86169303_makeRoomAtLast [
	"Make some empty slots at the end of the array. If we have more than 50% free space, then just move the elements, so that the last 50% of the slots are free, otherwise add new free slots to the end by growing. Precondition: lastIndex = array size"

	| tally newFirstIndex newLastIndex |
	tally := self size.
	tally * 2 >= lastIndex ifTrue: [
		^ self _pretenured_86169303_growAtLast ].
	tally = 0 ifTrue: [ ^ self resetTo: 1 ].
	newLastIndex := lastIndex // 2.
	newFirstIndex := newLastIndex - lastIndex + firstIndex.
	array
		replaceFrom: newFirstIndex
		to: newLastIndex
		with: array
		startingAt: firstIndex.
	array from: newLastIndex + 1 to: lastIndex put: nil.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_869662_addLast: newObject [
	"Add newObject to the end of the receiver. Answer newObject."

	lastIndex = array size ifTrue: [
		self _pretenured_869662_makeRoomAtLast ].
	lastIndex := lastIndex + 1.
	^ array at: lastIndex put: newObject
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_869662_growAtLast [
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

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
OrderedCollection >> _pretenured_869662_makeRoomAtLast [
	"Make some empty slots at the end of the array. If we have more than 50% free space, then just move the elements, so that the last 50% of the slots are free, otherwise add new free slots to the end by growing. Precondition: lastIndex = array size"

	| tally newFirstIndex newLastIndex |
	tally := self size.
	tally * 2 >= lastIndex ifTrue: [
		^ self _pretenured_869662_growAtLast ].
	tally = 0 ifTrue: [ ^ self resetTo: 1 ].
	newLastIndex := lastIndex // 2.
	newFirstIndex := newLastIndex - lastIndex + firstIndex.
	array
		replaceFrom: newFirstIndex
		to: newLastIndex
		with: array
		startingAt: firstIndex.
	array from: newLastIndex + 1 to: lastIndex put: nil.
	firstIndex := newFirstIndex.
	lastIndex := newLastIndex
]
