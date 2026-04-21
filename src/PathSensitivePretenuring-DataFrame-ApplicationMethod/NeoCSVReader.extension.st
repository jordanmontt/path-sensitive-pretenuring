Extension { #name : 'NeoCSVReader' }

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_161555457_next [
	"Read the next record.
	I will return an instance of recordClass."

	^ recordClassIsIndexable
		  ifTrue: [ self _pretenured_161555457_readNextRecordAsArray ]
		  ifFalse: [ self readNextRecordAsObject ]
]

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_161555457_readNextRecord [

	| record |
	record := self _pretenured_161555457_recordClassNew: fieldCount.
	fieldAccessors
		ifNil: [ self readNextRecordWithoutFieldAccessors: record ]
		ifNotNil: [ self readNextRecordWithFieldAccessors: record ].
	self handleEndOfRecord.
	^ record
]

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_161555457_readNextRecordAsArray [

	fieldAccessors ifNotNil: [
		self fieldCount: (fieldAccessors count: [ :each | each notNil ]) ].
	^ fieldCount
		  ifNil: [
				  | record |
				  record := self readFirstRecord.
				  self fieldCount: record size.
				  record ]
		  ifNotNil: [ self _pretenured_161555457_readNextRecord ]
]

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_161555457_recordClassNew: size [

	^ recordClass newTenured: size
]

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_669254415_next [
	"Read the next record.
	I will return an instance of recordClass."

	^ recordClassIsIndexable
		  ifTrue: [ self _pretenured_669254415_readNextRecordAsArray ]
		  ifFalse: [ self readNextRecordAsObject ]
]

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_669254415_readField [

	| field |
	field := self peekQuote
		         ifTrue: [ self readQuotedField ]
		         ifFalse: [ self _pretenured_669254415_readUnquotedField ].
	(field ~= emptyFieldValue and: [ emptyFieldInput notNil ]) ifTrue: [
		(emptyFieldInput value: field) ifTrue: [ ^ emptyFieldValue ] ].
	^ field
]

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_669254415_readNextRecord [

	| record |
	record := self recordClassNew: fieldCount.
	fieldAccessors
		ifNil: [
			self _pretenured_669254415_readNextRecordWithoutFieldAccessors:
				record ]
		ifNotNil: [ self readNextRecordWithFieldAccessors: record ].
	self handleEndOfRecord.
	^ record
]

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_669254415_readNextRecordAsArray [

	fieldAccessors ifNotNil: [
		self fieldCount: (fieldAccessors count: [ :each | each notNil ]) ].
	^ fieldCount
		  ifNil: [
				  | record |
				  record := self readFirstRecord.
				  self fieldCount: record size.
				  record ]
		  ifNotNil: [ self _pretenured_669254415_readNextRecord ]
]

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_669254415_readNextRecordWithoutFieldAccessors: record [

	1 to: fieldCount do: [ :each |
			record at: each put: self _pretenured_669254415_readField.
			each = fieldCount ifFalse: [ self handleSeparator ] ]
]

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_669254415_readUnquotedField [

	(self atEnd or: [ self peekSeparator or: [ self peekEndOfLine ] ])
		ifTrue: [ ^ emptyFieldValue ].
	^ self _pretenured_669254415_stringStreamContents: [ :stream |
			  [
			  self atEnd or: [ self peekSeparator or: [ self peekEndOfLine ] ] ]
				  whileFalse: [ stream nextPut: self nextChar ] ]
]

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
NeoCSVReader >> _pretenured_669254415_stringStreamContents: block [
	"Like String streamContents: block
	but reusing the underlying buffer for improved efficiency"

	stringStream ifNil: [ stringStream := (String new: 32) writeStream ].
	stringStream reset.
	block value: stringStream.
	^ stringStream _pretenured_669254415_contents
]
