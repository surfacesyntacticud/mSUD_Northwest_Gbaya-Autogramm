# Corpus specific variables
LANG=gya
SUD_FOLDER=/Users/guillaum/github/surfacesyntacticud/mSUD_Northwest_Gbaya-Autogramm/SUD_Northwest_Gbaya-Autogramm

# Universal variables
GREW=grew_dev
GRS_CONVERT=/Users/guillaum/github/surfacesyntacticud/conversions/grs/${LANG}
UD_TOOLS=/Users/guillaum/github/UniversalDependencies/tools
SUD_TOOLS=/Users/guillaum/github/surfacesyntacticud/tools


UD_FOLDER=/Users/guillaum/github/UniversalDependencies/UD_Northwest_Gbaya-Autogramm
UD_FILE=${UD_FOLDER}/${LANG}_autogramm-ud-test.conllu

doc:
# 	@echo "make msud     ---> normalise with Grew"
	@echo "make sud      ---> build word-based SUD version"
	@echo "make ud       ---> build UD version (both word and morph based)"
	@echo "make validate ---> validate the Word-based UD version"

# 3 files 2.18
# FILES=GYA_PRD_NARR_01_T16-C6.conllu GYA_PRD_NARR_T24-C59.conllu GYA_PRD_NARR_T9-C7.conllu
FILES=GYA_PRD_NARR_01_T16-C6.conllu GYA_PRD_NARR_T24-C59.conllu GYA_PRD_NARR_T9-C7.conllu GYA_PRD_NARR_T35-C301.conllu

sud:
	mkdir -p ${SUD_FOLDER}
	for infile in ${FILES} ; do \
		outfile=${SUD_FOLDER}/$$infile ; \
		echo "$$infile --> $$outfile" ; \
		${GREW} transform -text_from_tokens -config sud -grs ${GRS_CONVERT}/gya_mSUD_to_SUD.grs -strat gya_mSUD_to_SUD_main -i $$infile -o $$outfile ; \
	done
	rm -f tmp.conllu

ud: sud
	for conllu in ${FILES} ; do \
		infile=${SUD_FOLDER}/$$conllu; \
		outfile=${UD_FOLDER}/not-to-release/$$conllu ; \
		echo "$$infile --> $$outfile" ; \
		${GREW} transform -config sud -grs ${GRS_CONVERT}/${LANG}_SUD_to_UD.grs -strat ${LANG}_SUD_to_UD_main -i $$infile -o $$outfile ; \
	done
	@make build_ud

build_ud:
	echo "# global.columns = ID FORM LEMMA UPOS XPOS FEATS HEAD DEPREL DEPS MISC" > ${UD_FILE}
	for file in ${FILES} ; do \
		cat ${UD_FOLDER}/not-to-release/$$file | grep -v "# global.columns" >> ${UD_FILE} ; \
	done

validate:
	${UD_TOOLS}/validate.py --max-err=0 --no-warnings --lang=${LANG} ${UD_FILE}


# ======================================================================================
GE:
	grep GE *.conllu | cut -f 10 | tr "|" "\n" | grep GE | sed "s/^GE=//" | sort -u > GE.list

MGloss:
	grep MGloss word_based/*.conllu | cut -f 10 | tr "|" "\n" | grep MGloss | sed "s/^GE=//" | sort -u

# ======================================================================================
# unused
# ======================================================================================
mSUD_FOLDER=/Users/guillaum/github/surfacesyntacticud/mSUD_Northwest_Gbaya-Autogramm/mSUD_Northwest_Gbaya-Autogramm
xxx:
	mkdir -p ${mSUD_FOLDER}
	for infile in *.conllu ; do \
		outfile=${mSUD_FOLDER}/$$infile ; \
		echo "$$infile --> $$outfile" ; \
		${GREW} transform -text_from_tokens -config sud -grs xSUD_to_mSUD.grs -i $$infile -o $$outfile ; \
	done

tt:	
	for file in GYA*.conllu ; do \
		${GREW} transform -grs tokentype.grs -i $$file -o tmp.conllu ; \
		mv -f tmp.conllu $$file ; \
	done
	rm -r tmp.conllu


# normalisation:
# 1) run Grew: normalise Conll and unicode NFC
# 2) run script adding Word=xxx for SUD convertion
norm:
	for file in GYA*.conllu ; do \
		${GREW} transform -i $$file -o tmp.conllu ; \
		python3 add_word_to_misc.py tmp.conllu $$file ; \
	done
	rm -r tmp.conllu


msud:
	for file in ${FILES} ; do \
		echo $$file ; \
		${GREW} transform -i ArboratorGrew/$$file -o tmp.conllu ; \
		python3 tools/add_word_to_misc.py tmp.conllu $$file ; \
	done
	rm -f tmp.conllu
