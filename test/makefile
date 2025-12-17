TEXMFLOCAL   = $(shell kpsewhich --var-value TEXMFLOCAL)
STRIPTARGET  = bookkeeping.sty
DOCTARGET    = bookkeeping
PDFTARGET    = $(addsuffix .pdf,$(DOCTARGET))
TESTTARGET   = $(addsuffix .pdf,$(basename $(wildcard *.tex)))
DVITARGET    = $(addsuffix .dvi,$(DOCTARGET))
LATEXENGINE := uplatex #lualatex
LATEXOpt    := -interaction batchmode
LOGSUFFIXES  = .aux .log .toc .mx1 .mx2 .bcf .bbl .blg .idx .ind .ilg .out .run.xml .glo .gls .hd

define move
	$(foreach tempsuffix,$(LOGSUFFIXES),$(call movebase,$1,$(tempsuffix)))
	
endef
define movebase
	@if [ -e $(addsuffix $2,$1) ]; then mv $(addsuffix $2,$1) ./logs; fi
	
endef

define remove
	$(foreach tempsuffix,$(LOGSUFFIXES),$(call movebase,$1,$(tempsuffix)))
	
endef
define removebase
	@if [ -e $(addsuffix $2,$1) ]; then rm -f $(addsuffix $2,$1) ; fi
	
endef
.PHONY: all strip doc test install clean cleanall cleandoc movelog makelog

default: $(TESTTARGET)
all: $(STRIPTARGET) $(PDFTARGET)
strip: $(STRIPTARGET)
doc: $(PDFTARGET)
test: $(TESTTARGET)

test.pdf: test.tex ../bookkeeping.sty
test-PJ.pdf: test-PJ.tex ../bookkeeping.sty

ifeq ($(LATEXENGINE),lualatex)
%.pdf: %.tex
	lualatex $(LATEXOpt) $<
	if [ -e $(basename $<).idx ]; then makeindex -q -s gind.ist $(basename $<); fi
	if [ -e $(basename $<).glo ];\
		then makeindex -q -s gglo.ist -o $(addsuffix .gls,$(basename $<)) $(addsuffix .glo,$(basename $<)); fi
	lualatex $(LATEXOpt) -synctex=1 $<
	$(MAKE) movelog DOCTARGET=$(basename $(notdir $<))
else
%.dvi: %.tex
	$(LATEXENGINE) $(LATEXOpt) $<
	$(LATEXENGINE) $(LATEXOpt) -synctex=1 $<
	$(MAKE) movelog DOCTARGET=$(basename $(notdir $<))

%.pdf: %.dvi
	dvipdfmx $<
endif

install: $(STRIPTARGET) $(PDFTARGET)
	@mkdir -p $(TEXMFLOCAL)/tex/platex/bellMacros
	install $(STRIPTARGET) $(TEXMFLOCAL)/tex/platex/bellMacros
	@mkdir -p $(TEXMFLOCAL)/doc/platex/bellMacros
	install $(PDFTARGET) $(TEXMFLOCAL)/doc/platex/bellMacros

movelog:
	@mkdir -p ./logs
	$(foreach temp,$(DOCTARGET),$(call move,$(temp)))

clean:
	$(foreach temp,$(DOCTARGET),$(call remove,$(temp)))

cleanall:
	@rm -f $(PDFTARGET) $(DVITARGET) $(STRIPTARGET)
	make clean

makelog:
	@git log --graph --date=short --all --pretty="format:(%C(yellow)%h) %C(cyan)%ad \"%C(green)%an\"%C(reset)%x09%C(red)%d%C(reset) %s" 1> "log_all.gitlog"
	@git log --graph --date=short       --pretty="format:(%C(yellow)%h) %C(cyan)%ad \"%C(green)%an\"%C(reset)%x09%C(red)%d%C(reset) %s" 1> "log.gitlog"
