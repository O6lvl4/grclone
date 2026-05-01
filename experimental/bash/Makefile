LOCAL  ?= $(HOME)/Downloads/経理-gdrive
REMOTE ?= gdrive:
RCLONE ?= rclone
BISYNC_LOG := $(HOME)/Library/Caches/rclone/bisync

RECEIPTS_DIR ?= $(HOME)/Downloads/経理/領収書
RECEIPTS_PLAN ?= /tmp/receipts-rename-plan.tsv

.PHONY: help status fetch diff pull push sync resync dry-pull dry-push dry-sync log clean-lock \
        receipts-lint receipts-plan receipts-apply

help: ## ヘルプ表示
	@awk 'BEGIN{FS=":.*## "} /^[a-zA-Z_-]+:.*## / {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

status: ## 差分サマリ（どちらに何があるか）
	@echo "── remote にしかない（pull で取得）──"
	@$(RCLONE) check $(REMOTE) $(LOCAL) --missing-on-dst /dev/stdout 2>/dev/null || true
	@echo
	@echo "── local にしかない（push で送出）──"
	@$(RCLONE) check $(LOCAL) $(REMOTE) --missing-on-dst /dev/stdout 2>/dev/null || true
	@echo
	@echo "── 内容が違うファイル ──"
	@$(RCLONE) check $(LOCAL) $(REMOTE) --differ /dev/stdout 2>/dev/null || true

fetch: status ## status のエイリアス（git fetch 相当：書き込みなしで状態確認）

diff: ## 全件の比較結果（= equal, * differ, + missing on dst, - missing on src）
	@$(RCLONE) check $(LOCAL) $(REMOTE) --combined - 2>&1 | grep -v '^=' || true

pull: ## remote → local（remote を正として上書き・削除あり）
	$(RCLONE) sync $(REMOTE) $(LOCAL) --progress

push: ## local → remote（local を正として上書き・削除あり）
	$(RCLONE) sync $(LOCAL) $(REMOTE) --progress

sync: ## 双方向同期（bisync）
	$(RCLONE) bisync $(LOCAL) $(REMOTE) --progress

resync: ## bisync のベースライン再構築（remote 優先）
	$(RCLONE) bisync $(LOCAL) $(REMOTE) --resync --resync-mode path2 --progress

dry-pull: ## pull のプレビュー
	$(RCLONE) sync $(REMOTE) $(LOCAL) --dry-run

dry-push: ## push のプレビュー
	$(RCLONE) sync $(LOCAL) $(REMOTE) --dry-run

dry-sync: ## sync のプレビュー
	$(RCLONE) bisync $(LOCAL) $(REMOTE) --dry-run

log: ## 直近の bisync ログ
	@ls -t $(BISYNC_LOG)/*.log 2>/dev/null | head -1 | xargs -I{} tail -n 80 {} 2>/dev/null || echo "(no log)"

clean-lock: ## bisync のロックファイル削除（異常終了時のリカバリ）
	rm -f $(BISYNC_LOG)/*.lck && echo "lock removed"

receipts-lint: ## 領収書ディレクトリのlint（命名規則違反検出）
	@RECEIPTS_DIR="$(RECEIPTS_DIR)" bash scripts/receipts-lint.sh "$(RECEIPTS_DIR)"

receipts-plan: ## 領収書のリネーム案を生成（TSV出力、書き込みなし）
	@RECEIPTS_DIR="$(RECEIPTS_DIR)" RECEIPTS_PLAN="$(RECEIPTS_PLAN)" bash scripts/receipts-rename-plan.sh

receipts-apply: ## TSVを基にリネーム実行（plan後に目視レビュー必須）
	@RECEIPTS_DIR="$(RECEIPTS_DIR)" RECEIPTS_PLAN="$(RECEIPTS_PLAN)" bash scripts/receipts-rename-apply.sh
