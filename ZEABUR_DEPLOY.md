# Zeabur deploy form cheat sheet

## Option A: GitHub repo directly
如果你用 Zeabur 直接連 GitHub repo：
- Source: GitHub
- Repository: `Edwardlee-AI/zeabur-infinity-rag`
- Branch: `main`
- Build Method: Dockerfile
- Dockerfile Path: `./Dockerfile`
- Port: `1234`
- Health Check Path: `/docs`

## Option B: GHCR image
如果你用 GHCR image：
- Source: Image
- Image: `ghcr.io/edwardlee-ai/zeabur-infinity-rag-deploy:latest`
- Port: `1234`
- Health Check Path: `/docs`

## Env
```text
PORT=1234
INFINITY_API_KEY=<你自定義>
EMBED_MODEL_ID=mixedbread-ai/mxbai-embed-large-v1
RERANK_MODEL_ID=Qwen/Qwen3-Reranker-0.6B
EMBED_MODEL_NAME=text-embedding-mxbai-embed-large-v1
RERANK_MODEL_NAME=qwen3-reranker-0.6b
INFINITY_ENGINE=optimum
INFINITY_DEVICE=cpu
EMBED_BATCH_SIZE=8
RERANK_BATCH_SIZE=2
```

## Resource suggestion
### Minimum
- 4 vCPU
- 8 GB RAM

### Better
- 8 vCPU
- 16 GB RAM

## Notes
- 首次部署會下載 Hugging Face model，耐少少係正常
- 如果 build / startup time 太短就死，多數係 memory 唔夠或者 model download fail
- CPU reranker 慢係正常，candidate pool 唔好一開始設太大
