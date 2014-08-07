build:
	-rm -f db.json
	-rm -rf public/
	hexo generate

publish:
	hexo deploy


.PHONY: build publish
