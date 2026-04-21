Extension { #name : 'FreeTypeFont' }

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
FreeTypeFont >> _pretenured_333867595_widthAndKernedWidthOfLeft: leftCharacter right: rightCharacterOrNil into: aTwoElementArray [
	"Set the first element of aTwoElementArray to the width of leftCharacter and
	the second element to the width of left character when kerned with
	rightCharacterOrNil. Answer the receiver

	We use a widthAndKernedWidthCache to store these values for speed"

	| privateArray |
	privateArray := (self widthAndKernedWidthCache
		                 at: leftCharacter
		                 ifAbsentPut: [ Dictionary new ])
		                at: (rightCharacterOrNil ifNil: [ 0 asCharacter ])
		                ifAbsentPut: [
				                super
					                widthAndKernedWidthOfLeft: leftCharacter
					                right: rightCharacterOrNil
					                into: (Array newTenured: 2) ].
	"We can't answer privateArray, we MUST copy its elements into aTwoElementArray"
	aTwoElementArray
		at: 1 put: (privateArray at: 1);
		at: 2 put: (privateArray at: 2).
	^ aTwoElementArray
]

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
FreeTypeFont >> _pretenured_382711116_widthAndKernedWidthOfLeft: leftCharacter right: rightCharacterOrNil into: aTwoElementArray [
	"Set the first element of aTwoElementArray to the width of leftCharacter and
	the second element to the width of left character when kerned with
	rightCharacterOrNil. Answer the receiver

	We use a widthAndKernedWidthCache to store these values for speed"

	| privateArray |
	privateArray := (self widthAndKernedWidthCache
		                 at: leftCharacter
		                 ifAbsentPut: [ Dictionary new ])
		                at: (rightCharacterOrNil ifNil: [ 0 asCharacter ])
		                ifAbsentPut: [
				                super
					                widthAndKernedWidthOfLeft: leftCharacter
					                right: rightCharacterOrNil
					                into: (Array newTenured: 2) ].
	"We can't answer privateArray, we MUST copy its elements into aTwoElementArray"
	aTwoElementArray
		at: 1 put: (privateArray at: 1);
		at: 2 put: (privateArray at: 2).
	^ aTwoElementArray
]
