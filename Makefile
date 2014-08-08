GRAPH_DIR=cdn/images/graph


GRAPH_DOTS:=$(wildcard dots/*.dot)
GRAPH_PNGS:=$(addprefix $(GRAPH_DIR)/,$(notdir $(GRAPH_DOTS:.dot=.png)))

graph: $(GRAPH_PNGS)


$(GRAPH_PNGS): $(GRAPH_DIR)


$(GRAPH_DIR)/%.png: dots/%.dot
	dot $< -Tpng -o $@

$(GRAPH_DIR):
	-mkdir -p $(GRAPH_DIR)

sync:
	.qiniu/qrsync.exe .qiniu.json

build: graph
	hexo clean
	hexo generate

publish: build
	hexo deploy


.PHONY: build publish graph sync
