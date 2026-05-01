LOCAL  ?= $(HOME)/Downloads/経理-gdrive
REMOTE ?= gdrive:
RCLONE ?= rclone
BISYNC_LOG := $(HOME)/Library/Caches/rclone/bisync

.PHONY: help status fetch diff pull push sync resync dry-pull dry-push dry-sync log clean-lock

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
