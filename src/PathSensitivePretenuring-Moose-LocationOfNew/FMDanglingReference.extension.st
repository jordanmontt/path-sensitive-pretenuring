Extension { #name : 'FMDanglingReference' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
FMDanglingReference class >> _pretenured_872263312_with: aFutureAttribute [

	^ self newTenured
		  parentProperty: aFutureAttribute;
		  yourself
]
