GRAPH_DIR=cdn/images/graph

GRAPH_DOTS:=$(wildcard dots/*.dot)
GRAPH_PNGS:=$(addprefix $(GRAPH_DIR)/,$(notdir $(GRAPH_DOTS:.dot=.png)))


$(GRAPH_PNGS): $(GRAPH_DIR)

$(GRAPH_DIR)/%.png: dots/%.dot
	dot $< -Tpng -o $@

$(GRAPH_DIR):
	-mkdir -p $(GRAPH_DIR)

graph: $(GRAPH_PNGS)

sync: graph
	qshell qupload .qupload.json

build:
	hexo generate

deploy: build
	hexo deploy


.PHONY: build deploy graph sync
