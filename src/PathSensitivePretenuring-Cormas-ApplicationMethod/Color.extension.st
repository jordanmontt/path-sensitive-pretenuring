Extension { #name : 'Color' }

{ #category : '*PathSensitivePretenuring-Cormas-ApplicationMethod' }
Color class >> _pretenured_186316203_fromHexString: aColorHex [
	"Returns a color instance from HEX (6 element elements)."

	"(Color fromHexString: 'FFFFFF')>>> (Color white) "

	| green red blue alpha hexString |
	hexString := aColorHex withoutPrefix: '#'.
	red := (Integer readFrom: (hexString first: 2) base: 16) / 255.
	green := (Integer readFrom: (hexString copyFrom: 3 to: 4) base: 16)
	         / 255.
	blue := (Integer readFrom: (hexString copyFrom: 5 to: 6) base: 16)
	        / 255.

	alpha := hexString size = 8
		         ifFalse: [ 1.0 ]
		         ifTrue: [
		         (Integer readFrom: (hexString copyFrom: 7 to: 8) base: 16)
		         / 255 ].

	^ self
		  _pretenured_186316203_r: red
		  g: green
		  b: blue
		  alpha: alpha
]

{ #category : '*PathSensitivePretenuring-Cormas-ApplicationMethod' }
Color class >> _pretenured_186316203_r: r g: g b: b alpha: alpha [
	"Return a color with the given r, g, and b components in the range [0.0..1.0]."

	^ self basicNewTenured
		  initializeRed: r
		  green: g
		  blue: b
		  alpha: alpha;
		  yourself
]
