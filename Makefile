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

.PHONY: deploy-nas deploy-spark app-web app-android status test

deploy-nas:
	ssh $(NAS) 'mkdir -p $(NAS_DIR)'
	$(RSYNC) nas/ $(NAS):$(NAS_DIR)/
	ssh $(NAS) 'cd $(NAS_DIR) && test -f .env || cp .env.example .env; \
		docker compose -f ugc-stack.yaml up -d --build'

deploy-spark:
	ssh $(SPARK) 'mkdir -p $(SPARK_DIR)'
	$(RSYNC) spark/ $(SPARK):$(SPARK_DIR)/
	ssh $(SPARK) 'cd $(SPARK_DIR) && docker compose -f ugc-spark.yaml up -d --build'

app-web:
	cd app && flutter build web --release --base-href /app/
	rm -rf nas/web && cp -R app/build/web nas/web
	$(MAKE) deploy-nas

app-android:
	cd app && flutter build apk --release && flutter install --release

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
