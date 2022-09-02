package targets

import (
	"dagger.io/dagger/core"
	"universe.dagger.io/docker"
)

#Jammy: {
	ref: core.#Ref | *"buildpack-deps:jammy"

	_img: docker.#Pull & {
		source: ref
	}

	_build: #_Debbase & {
		prefix: "jammy"
		input:  _img.output
	}
	output: _build.output
}
