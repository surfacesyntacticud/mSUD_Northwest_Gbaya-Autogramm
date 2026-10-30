# Universal variables
GREW=grew_dev
UD_TOOLS=/Users/guillaum/github/UniversalDependencies/tools
SUD_TOOLS=/Users/guillaum/github/surfacesyntacticud/tools
UNIDIVE=/Users/guillaum/github/UniDive/SpLAn-UD/metadata-encoding

# Corpus specific variables
LANG=gya

UD_FOLDER=/Users/guillaum/github/UniversalDependencies/UD_Northwest_Gbaya-Autogramm
ORIGINAL_SPLIT=${UD_FOLDER}/not-to-release/original_split

doc:
	@echo "make norm       ---> normalise with Grew"
	@echo "make sud_full   ---> build word-based SUD version"
	@echo "make ud_full    ---> build the UD conversion"
	@echo ""
	@echo "make run_filter ---> build the subcorpus with full annotated sentences"
	@echo "make sud_filter ---> build word-based filtered SUD version"
	@echo "make ud_filter  ---> build filtered UD version"
	@echo ""
	@echo "⚠️ Make sure that `merge.json` is relevant with respect to filtered version"
	@echo "make ud         ---> update local UD github repo (⚠️ : from filtered)"
	@echo "make validate   ---> validate the Word-based UD version"


norm:
	for file in *.conllu ; do \
		${GREW} transform -i $$file -o tmp ; \
		mv -f tmp $$file ; \
	done

run_filter:
	mkdir -p filter
	python3 ${SUD_TOOLS}/MISC/extract_trees.py . filter/mSUD_Northwest_Gbaya-Autogramm

sud_full:
	${GREW} build SUD_Northwest_Gbaya-Autogramm@latest

ud_full:
	${GREW} build UD_Northwest_Gbaya-Autogramm@conv

sud_filter:
	${GREW} build SUD_Northwest_Gbaya-Autogramm@filter

ud_filter:
	${GREW} build UD_Northwest_Gbaya-Autogramm@filter


UD_CORPUS=UD_Northwest_Gbaya-Autogramm@filter
UD_BUILD_DIR=`grew_dev get_dir ${UD_CORPUS}`
ud:
	cp ${UD_BUILD_DIR}/*.conllu ${ORIGINAL_SPLIT}
	cp -f merge.json ${ORIGINAL_SPLIT}
	python3 ${UNIDIVE}/merge_and_unshare.py ${UD_FOLDER}

whole_filter:
	@make run_filter
	@make sud_filter
	@make ud_filter
	@make ud

validate:
	${GREW} validate ${UD_CORPUS}
	cat ${UD_BUILD_DIR}/_build_grew/${UD_CORPUS}/valid_ud.txt

diag:
	python3 ${SUDTOOLS}/UD/diag.py ${UD_BUILD_DIR}/_build_grew/${UD_CORPUS}/valid_ud.txt

# # ============================================================
# diag:
# 	echo "" > _UDVAL.txt
# 	for file in ${ORIGINAL_SPLIT}/*.conllu ; do \
# 		${UD_TOOLS}/validate.py --lang=${LANG} --max-err=0 $$file 2>> _UDVAL.txt || true ; \
# 	done
# 	@echo "========= Unknown UPOS tag ========="
# 	@grep "Unknown UPOS tag" _UDVAL.txt | cut -f 3- -d ":" |  sort | uniq -c | sort -nr
# 	@echo "========= Unknown DEPREL label ========="
# 	@grep "Unknown DEPREL label" _UDVAL.txt | cut -f 3- -d ":" |  sort | uniq -c | sort -nr
# 	@echo "========= feature-value-unknown ========="
# 	@grep "L4 MORPHO feature-value-unknown" _UDVAL.txt | cut -f 3- -d "]" | cut -f 1 -d "(" | sort | uniq -c | sort -nr 
# 	@echo "========= feature-upos-not-permitted ========="
# 	@grep "L4 MORPHO feature-upos-not-permitted" _UDVAL.txt | cut -f 3- -d "]" | cut -f 1 -d "(" | sort | uniq -c | sort -nr 
# 	@echo "========= feature-value-upos-not-permitted ========="
# 	@grep "L4 MORPHO feature-value-upos-not-permitted" _UDVAL.txt | cut -f 3- -d "]" | cut -f 1 -d "(" | sort | uniq -c | sort -nr 
# 	@echo "========= feature-not-permitted ========="
# 	@grep "L4 MORPHO feature-not-permitted" _UDVAL.txt | cut -f 3- -d "]" | cut -f 1 -d "(" | sort | uniq -c | sort -nr 
# 	@echo "========= feature-unknown ========="
# 	@grep "L4 MORPHO feature-unknown" _UDVAL.txt | cut -f 3- -d "]" | cut -f 1 -d "(" | sort | uniq -c | sort -nr 
# 	@echo "========= aux declaration ========="
# 	@grep "is not an auxiliary in language" _UDVAL.txt | cut -f 3- -d "]" | sort | uniq -c | sort -nr 
# 	@echo "========= cop declaration ========="
# 	@grep "is not a copula in language" _UDVAL.txt | cut -f 3- -d "]" | sort | uniq -c | sort -nr 
# 	@echo "========= Other issues ========="
# 	@cat _UDVAL.txt \
# 	| grep "Line" \
# 	| grep -v "WARNING" \
# 	| grep -v "Unknown DEPREL label" \
# 	| grep -v "Invalid DEPREL value" \
# 	| grep -v "feature-upos-not-permitted" \
# 	| grep -v "feature-value-upos-not-permitted" \
# 	| grep -v "feature-not-permitted" \
# 	| grep -v "feature-value-unknown" \
# 	| grep -v "feature-unknown" \
# 	| grep -v "Unknown UPOS tag" \
# 	| grep -v "is not an auxiliary in language" \
# 	| grep -v "is not a copula in language" \
# 	| grep -v "PASSED" || True


# ======================================================================================

run:
	for infile in *.conllu ; do \
		${GREW} transform -config sud -grs xxx.grs -i $$infile -o tmp ; \
		mv -f tmp $$infile ; \
	done


GE:
	grep GE *.conllu | cut -f 10 | tr "|" "\n" | grep GE | sed "s/^GE=//" | sort -u > GE.list

MGloss:
	grep MGloss word_based/*.conllu | cut -f 10 | tr "|" "\n" | grep MGloss | sed "s/^GE=//" | sort -u
