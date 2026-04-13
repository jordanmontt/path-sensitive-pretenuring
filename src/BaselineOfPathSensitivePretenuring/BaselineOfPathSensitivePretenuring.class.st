Class {
	#name : 'BaselineOfPathSensitivePretenuring',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPathSensitivePretenuring',
	#package : 'BaselineOfPathSensitivePretenuring'
}

{ #category : 'baselines' }
BaselineOfPathSensitivePretenuring >> baseline: spec [

	<baseline>
	spec for: #common do: [
		"Packages"
		spec package: 'PathSensitivePretenuring'.

		"External dependencies"
		spec baseline: 'SendersChainTransformer' with: [ spec repository: 'github://jordanmontt/senders-chain-transformer:main' ].
		spec baseline: 'PretenuringAdviceAlgorithm' with: [ spec repository: 'github://jordanmontt/Pretenuring-Advice-Algorithm:main' ].
		spec baseline: 'VeritasBenchSuite' with: [ spec repository: 'github://jordanmontt/PharoVeritasBenchSuite:main' ].
		"Linking external dependencies"
		spec package: 'PathSensitivePretenuring' with: [ spec requires: #( 'SendersChainTransformer' 'VeritasBenchSuite' 'PretenuringAdviceAlgorithm') ].

		"Groups"
		spec group: 'default' with: #( 'core' ).
		spec group: 'core' with: #( 'PathSensitivePretenuring' ) ]
]
