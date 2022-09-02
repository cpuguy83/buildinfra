package targets

import (
	"universe.dagger.io/go"
	"dagger.io/dagger"
)

Linux: "linux"

Targets: {
	"bionic": Linux
	"focal":  Linux
}

#Target: {
	id: string
	{
		id:     "bionic"
		kind:   Targets.bionic
		_img:   #Bionic
		output: _img.output
	} |
	{
		id:     "focal"
		kind:   Targets.focal
		_img:   #Focal
		output: _img.output
	}
}

#Base: {
	target: #Target

	{
		goRef:  string
		_build: go.#Configure & {
			input: target.output
			ref:   goRef
		}
		output: _build.output
	} | {
		goRoot: dagger.#FS
		_build: go.#Configure & {
			input:    target.output
			contents: goRoot
		}
		output: _build.output
	}
}
