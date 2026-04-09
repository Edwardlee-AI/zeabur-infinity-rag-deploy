# Publish guide

建議 repo 名：`zeabur-infinity-rag`
建議 GitHub repo：`Edwardlee-AI/zeabur-infinity-rag`
建議 image：`ghcr.io/edwardlee-ai/zeabur-infinity-rag-deploy:latest`

## 1) 喺 GitHub 建 private repo
用 GitHub UI 建：
- Owner: `Edwardlee-AI`
- Repo: `zeabur-infinity-rag`
- Visibility: **Private**
- 唔好預先加 README / gitignore / license（避免衝突）

## 2) 本地初始化並 push
喺 `/home/node/.openclaw/workspace/services/zeabur-infinity-rag` 跑：

```bash
cd /home/node/.openclaw/workspace/services/zeabur-infinity-rag

git init
git branch -M main
git add .
git commit -m "feat: initial zeabur infinity rag service"
git remote add origin git@github.com:Edwardlee-AI/zeabur-infinity-rag.git
# 如果 SSH 未設好，就改用 HTTPS remote:
# git remote add origin https://github.com/Edwardlee-AI/zeabur-infinity-rag.git

git push -u origin main
```

## 3) GHCR
repo push 完之後，`.github/workflows/docker-publish.yml` 會自動 build 同 push 去 GHCR。

預期 image tag：
- `ghcr.io/edwardlee-ai/zeabur-infinity-rag-deploy:latest`
- `ghcr.io/edwardlee-ai/zeabur-infinity-rag-deploy:sha-<commit>`

## 4) 首次檢查 GitHub Actions
```bash
gh run list --repo Edwardlee-AI/zeabur-infinity-rag --limit 5
gh run view --repo Edwardlee-AI/zeabur-infinity-rag --log-failed
```

## 5) GHCR package visibility
建議：
- repo 保持 **Private**
- package 視情況 keep private
- Zeabur 如果拉 private GHCR image，要喺 Zeabur 設 registry credentials

## 6) Zeabur 掛 image
### Image
```text
ghcr.io/edwardlee-ai/zeabur-infinity-rag-deploy:latest
```

### Port
```text
1234
```

### Health Check Path
```text
/docs
```

### Required Env
```text
PORT=1234
INFINITY_API_KEY=<你自定義>
EMBED_MODEL_ID=mixedbread-ai/mxbai-embed-large-v1
RERANK_MODEL_ID=Qwen/Qwen3-Reranker-0.6B
EMBED_MODEL_NAME=text-embedding-mxbai-embed-large-v1
RERANK_MODEL_NAME=qwen3-reranker-0.6b
INFINITY_ENGINE=torch
INFINITY_DEVICE=cpu
INFINITY_MODEL_WARMUP=false
INFINITY_COMPILE=false
INFINITY_BETTERTRANSFORMER=false
EMBED_BATCH_SIZE=4
RERANK_BATCH_SIZE=1
```

## 7) 部署後驗證
### embeddings
```bash
curl -sS http://<zeabur-host>:1234/v1/embeddings \
  -H "Authorization: Bearer <INFINITY_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"model":"text-embedding-mxbai-embed-large-v1","input":["hello world"]}'
```

### rerank
```bash
curl -sS http://<zeabur-host>:1234/rerank \
  -H "Authorization: Bearer <INFINITY_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3-reranker-0.6b","query":"memory retrieval","documents":["use embeddings","use reranker"]}'
```

## 8) memory-lancedb-pro 對接前提
一定要先驗證：
- `/v1/embeddings` 真係返回 vector
- `/rerank` 真係返回 scores / ranking

驗證通過後先 patch `plugins.entries.memory-lancedb-pro.config`
