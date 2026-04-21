Extension { #name : 'DataFrameCsvReader' }

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
DataFrameCsvReader >> readOnlyRowsWith: aReader [

	rows := OrderedCollection new.

	[ aReader atEnd ] whileFalse: [
		rows add: aReader _pretenured_161555457_next ]
]
