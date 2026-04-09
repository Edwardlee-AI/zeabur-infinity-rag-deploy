# Zeabur Infinity embedding + reranker service

你講得啱，正路應該係：
**GitHub repo / GHCR image -> Zeabur service**

呢個 pack 而家已經補成可獨立做 repo / image，提供：
- `/v1/embeddings` -> `text-embedding-bge-large-en-v1.5`
- `/rerank` -> `bge-reranker-base`

實際載入嘅 Hugging Face models：
- embedding: `BAAI/bge-large-en-v1.5`
- reranker: `BAAI/bge-reranker-base`

## 檔案
- `Dockerfile`
- `start.sh`
- `.gitignore`
- `.dockerignore`
- `.github/workflows/docker-publish.yml`
- `.env.example`
- `memory-lancedb-pro.config.example.json`
- `PUBLISH.md`
- `ZEABUR_DEPLOY.md`

## 建議部署流
### Flow A: GitHub repo -> Zeabur 直接用 Dockerfile build
- 把成個目錄變成一個 GitHub repo
- Zeabur 連 GitHub repo
- 用 Dockerfile build
- 開一個獨立 service
- 對外 port: `1234`

### Flow B: GitHub repo -> GHCR image -> Zeabur 用 image deploy
- push 去 GitHub
- GitHub Actions 自動 build/push 去 `ghcr.io/<owner>/zeabur-infinity-rag-deploy`
- Zeabur 直接食 GHCR image

如果你要穩定 repeatable deploy，我偏向 **Flow B**。

## Zeabur 部署建議
### Runtime
- GitHub 直連 Dockerfile，或者 GHCR image
- 開一個獨立 service
- 對外 port: `1234`

### Environment Variables
最少要設：
- `PORT=1234`
- `INFINITY_API_KEY=<你自己定義嘅 key>`
- `EMBED_MODEL_ID=BAAI/bge-large-en-v1.5`
- `RERANK_MODEL_ID=BAAI/bge-reranker-base`
- `EMBED_MODEL_NAME=text-embedding-bge-large-en-v1.5`
- `RERANK_MODEL_NAME=bge-reranker-base`
- `INFINITY_ENGINE=torch`
- `INFINITY_DEVICE=cpu`
- `INFINITY_MODEL_WARMUP=false`
- `INFINITY_COMPILE=false`
- `INFINITY_BETTERTRANSFORMER=false`
- `EMBED_BATCH_SIZE=4`
- `RERANK_BATCH_SIZE=1`

## 資源建議
### 最低可試
- 4 vCPU
- 8 GB RAM

### 較穩陣
- 8 vCPU
- 16 GB RAM

原因：
- `BAAI/bge-large-en-v1.5` + `BAAI/bge-reranker-base` 係較穩陣、較易喺 CPU 起得返嘅組合
- `mixedbread-ai/mxbai-embed-large-v1` 雖然模型存在，但喺當前 Infinity/base image loader 組合上會出現 model load failure
- `Qwen/Qwen3-Reranker-0.6B` 會撞到 base image 內 `transformers` 對 `qwen3` architecture 未識別，startup 直接死
- 關掉 startup warmup / compile / bettertransformer，可減少 Zeabur startup phase 爆掉機會
- 首次 cold start 會下載模型，時間可能幾分鐘

## Health check 建議
Zeabur health path 先設：
- `/docs`

原因：
- Infinity 係 FastAPI server，`/docs` 通常最穩
- 真正功能健康度另外用下列 curl 手動驗證

## 部署後驗證
### Embedding
```bash
curl -sS http://<host>:1234/v1/embeddings \
  -H "Authorization: Bearer <LM_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "text-embedding-bge-large-en-v1.5",
    "input": ["hello world", "memory retrieval test"]
  }'
```

### Rerank
```bash
curl -sS http://<host>:1234/rerank \
  -H "Authorization: Bearer <LM_API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "bge-reranker-base",
    "query": "best memory retrieval setup",
    "documents": [
      "Use BGE embeddings for retrieval.",
      "Use BM25 only.",
      "Configure local reranker for better precision."
    ]
  }'
```

## memory-lancedb-pro 對接
示例 config 喺：
- `memory-lancedb-pro.config.example.json`

重點：
- plugin 仍然要用 `embedding.provider = "openai-compatible"`
- 唔係 `local`
- `rerankEndpoint` 指返你個 Zeabur service `/rerank`

## 風險
- CPU only reranker 會慢，尤其 candidate pool 大時
- 如果 Zeabur memory limit 太細，service 會 OOM 或瘋狂重啟
- 首次 build / pull model 時間長，唔好太快判斷部署失敗

## GitHub / GHCR 要點
如果用 GitHub Actions 推 GHCR：
- repo 預設用 `main` branch
- workflow 已經寫好，push 去 `main` 就會 build + push
- image 名：`ghcr.io/<github-owner>/zeabur-infinity-rag-deploy:latest`

## 我建議嘅落地順序
1. 先將呢個目錄做成獨立 GitHub repo
2. push 上 GitHub
3. 等 Actions build GHCR image
4. Zeabur 掛 image 或直接掛 repo
5. 驗證 `/v1/embeddings`
6. 再驗證 `/rerank`
7. 最後先 patch `memory-lancedb-pro`
