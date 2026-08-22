# UGCFactory — nasazeni cele tovarny z jednoho mista.
#
#   make deploy-nas     # ugc-api + blender worker + tunnel na JODA
#   make deploy-spark   # ugc-pipeline na SPARK
#   make app-web        # web build appky -> nas/web -> redeploy NAS
#   make app-android    # APK na pripojeny telefon
#   make status         # zdravi vsech sluzeb

NAS  ?= joda
SPARK ?= spark
NAS_DIR   ?= ~/deploy/UGCFactory/nas
SPARK_DIR ?= ~/deploy/UGCFactory/spark
RSYNC := rsync -a --exclude .git --exclude __pycache__ --exclude build

# Access service token pro ugc.ol1n.com. Zije v app/.cf-token (gitignored)
# a zabuduje se do appky pres --dart-define, aby nebyl ve verejnem repu.
CF_TOKEN_FILE := app/.cf-token
DART_DEFINES := $(shell test -f $(CF_TOKEN_FILE) && \
	sed -n 's/^\([A-Z_]*\)=\(.*\)$$/--dart-define=\1=\2/p' $(CF_TOKEN_FILE) | tr '\n' ' ')

.PHONY: deploy-nas deploy-spark app-web app-android status test

# credentials.json je mimo git (tunnel secret) - deploy ho nesmi prepsat
# ani ztratit; pri prvnim nasazeni ho tam poloz rucne s pravy 0444
# (konektor bezi jako uid 65532 a na 0400 dostane permission denied).
deploy-nas:
	ssh $(NAS) 'mkdir -p $(NAS_DIR)/cloudflared'
	$(RSYNC) --exclude cloudflared/credentials.json nas/ $(NAS):$(NAS_DIR)/
	@ssh $(NAS) 'test -s $(NAS_DIR)/cloudflared/credentials.json' \
		|| echo "POZOR: chybi $(NAS_DIR)/cloudflared/credentials.json - tunnel nenabehne"
	@# .env se NIKDY neprepisuje (drzi tajemstvi), ale chybejici klice se
	@# doplni ze sablony - jinak stary .env tise vynecha novy parametr
	@# a projevi se to az za behu ("SPARK_GENERATE_URL not configured").
	ssh $(NAS) 'cd $(NAS_DIR) && touch .env && \
		while IFS= read -r line; do \
			case "$$line" in \
				\#*|"") continue;; \
			esac; \
			key=$${line%%=*}; \
			grep -q "^$$key=" .env || { echo "$$line" >> .env; echo "  .env: doplnen $$key"; }; \
		done < .env.example; \
		docker compose -f ugc-stack.yaml up -d --build'
	@ssh $(NAS) 'cd $(NAS_DIR); for k in DATA_DIR SPARK_GENERATE_URL; do \
		grep -q "^$$k=." .env || echo "POZOR: $$k je v .env prazdny"; done'


deploy-spark:
	ssh $(SPARK) 'mkdir -p $(SPARK_DIR)'
	$(RSYNC) spark/ $(SPARK):$(SPARK_DIR)/
	ssh $(SPARK) 'cd $(SPARK_DIR) && docker compose -f ugc-spark.yaml up -d --build'

app-web:
	cd app && flutter build web --release --base-href /app/ $(DART_DEFINES)
	rm -rf nas/web && cp -R app/build/web nas/web
	$(MAKE) deploy-nas

app-android:
	cd app && flutter build apk --release $(DART_DEFINES) && flutter install --release

# iOS jde nasadit i bezdratove (zarizeni sparovane pres Xcode). Podepisuje
# se automaticky tymem P82HWPG7FN z Runner.xcodeproj.
IPHONE ?= 00008101-001175D90AA0001E
app-ios:
	cd app && flutter build ios --release $(DART_DEFINES) && flutter install -d $(IPHONE) --release

status:
	@echo "== NAS ugc-api ==";     ssh $(NAS) 'curl -s localhost:8095/healthz' || true; echo
	@echo "== NAS blender ==";     ssh $(NAS) 'docker ps --filter name=blender --format "{{.Status}}"' || true
	@echo "== SPARK pipeline =="; ssh $(SPARK) 'curl -s localhost:8092/health' || true; echo
	@echo "== ComfyUI ==";        ssh $(SPARK) 'curl -s -o /dev/null -w "%{http_code}\n" localhost:8188/system_stats' || true
	@echo "== verejne ==";        curl -s -o /dev/null -w "ugc.ol1n.com/app/ %{http_code} (302 = Access chrani)\n" https://ugc.ol1n.com/app/

test:
	cd nas && go test ./...
	cd spark && go vet ./...
	cd app && flutter test
