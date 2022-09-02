package targets

import (
	"universe.dagger.io/docker"
	"universe.dagger.io/alpha/debian/apt"
)

#_Debbase: {
	input:  docker.#Image
	prefix: string

	apt.#Install & {
		cachePrefix: prefix
		packages: {
			"libseccomp-dev": {}
			"go-md2man": {}
		}
	}
}
