TARGET = $(basename $(filter-out HEADER.tex,$(wildcard *.tex)))
SRC = $(addsuffix .tex,$(TARGET))
PDFTARGET = $(addsuffix .pdf,$(TARGET))
DVITARGET = $(addsuffix .dvi,$(TARGET))
MX2TARGET = $(addsuffix .mx2,$(TARGET))
BIBTARGET = $(addsuffix .bbl,$(TARGET))
MDXTARGET = $(addsuffix .ind,$(TARGET))
DVIPDFMxOpt = #-f otf-up-yu-win10_mod otf-up-sourcehan #
LOGSUFFIXES = .aux .log .toc .mx1 .mx2 .bcf .bbl .blg .idx .ind .ilg .out .run.xml
LATEXENGINE := uplatex
DVIWARE := dvipdfmx

define move
	$(foreach tempsuffix,$(LOGSUFFIXES),$(call movebase,$1,$(tempsuffix)))
	
endef
define movebase
	if [ -e $(addsuffix $2,$1) ]; then mv $(addsuffix $2,$1) ./logs; fi
	
endef


all: $(PDFTARGET)
muflx: $(MX2TARGET)
biblio: $(BIBTARGET)
makeindex: $(MDXTARGET)

.SUFFIXES: .pdf .dvi .tex .mx2 .mx1 .bbl .bcf .ind .idx

%.dvi: %.tex
	uplatex $(notdir $<)
	if [ -e $(basename $(notdir $<)).mx1 ]; then $(MAKE) -B $(basename $(notdir $<)).mx2; uplatex $(notdir $<) ;fi
	if [ -e $(basename $(notdir $<)).bcf ]; then $(MAKE) -B $(basename $(notdir $<)).bbl; fi
	if [ -e $(basename $(notdir $<)).idx ]; then $(MAKE) -B $(basename $(notdir $<)).ind; fi
	uplatex $(notdir $<)
	uplatex -synctex=1 $(notdir $<)
	$(MAKE) movelog TARGET=$(basename $(notdir $<))

%.pdf: %.dvi
	dvipdfmx $(DVIPDFMxOpt) $(notdir $<)

%.mx2: %.mx1
	musixflx $(notdir $<)

%.bbl: %.bcf
	biber $(notdir $<)

%.ind: %.idx
	upmendex -s gcmc.ist -d dictU.dic -f $(notdir $<)

movelog:
	mkdir -p ./logs
	$(foreach temp,$(TARGET),$(call move,$(temp)))

clean:
	rm -f $(DVITARGET)
	$(MAKE) movelog

makelog:
	git log --oneline --decorate --graph --all 1> "log_all.txt"
	git log --oneline --decorate --graph 1> "log.txt"
