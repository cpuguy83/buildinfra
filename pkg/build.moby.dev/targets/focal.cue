package targets

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#Focal: {
	ref: core.#Ref | *"buildpack-deps:focal"

	_img: docker.#Pull & {
		source: ref
	}

	_build: #_Debbase & {
		prefix: "focal"
		input:  _img.output
	}
	output: _build.output
}
