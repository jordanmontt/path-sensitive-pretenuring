Extension { #name : 'Dictionary' }

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
Dictionary >> _pretenured_333867595_at: key ifAbsent: aBlock [
	"Answer the value associated with the key or, if key isn't found,
	answer the result of evaluating aBlock."

	^ ((array at: (self findElementOrNil: key))
		   ifNil: [ aBlock ]
		   ifNotNil: [ :assoc | assoc ]) value
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
Dictionary >> _pretenured_333867595_at: key ifAbsentPut: aBlock [
	"Return the value at the given key.
	If the key is not included in the receiver store and return the result
	of evaluating aBlock as the new value."

	^ self at: key ifAbsent: [ self at: key put: aBlock value ]
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
Dictionary >> _pretenured_382711116_at: key ifAbsent: aBlock [
	"Answer the value associated with the key or, if key isn't found,
	answer the result of evaluating aBlock."

	^ ((array at: (self findElementOrNil: key))
		   ifNil: [ aBlock ]
		   ifNotNil: [ :assoc | assoc ]) value
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
Dictionary >> _pretenured_382711116_at: key ifAbsentPut: aBlock [
	"Return the value at the given key.
	If the key is not included in the receiver store and return the result
	of evaluating aBlock as the new value."

	^ self
		  _pretenured_382711116_at: key
		  ifAbsent: [ self at: key put: aBlock value ]
]
