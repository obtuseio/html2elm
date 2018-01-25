default:

deploy: dist
	rm -rf dist
	yarn build --no-clear
	cd dist && rsync -avz --progress -h . obtuse:/srv/http/html2elm.obtuse.io/htdocs/

.PHONY: default deploy