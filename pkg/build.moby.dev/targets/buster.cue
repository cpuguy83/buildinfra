package targets

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#Buster: {
	ref: core.#Ref | *"buildpack-deps:buster"

	_img: docker.#Pull & {
		source: ref
	}

	_build: #_Debbase & {
		prefix: "buster"
		input:  _img.output
	}
	output: _build.output
}
