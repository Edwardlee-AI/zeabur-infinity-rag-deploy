#!/bin/sh
set -eu

PORT="${PORT:-1234}"
API_KEY="${INFINITY_API_KEY:-}"
EMBED_MODEL_ID="${EMBED_MODEL_ID:-mixedbread-ai/mxbai-embed-large-v1}"
EMBED_MODEL_NAME="${EMBED_MODEL_NAME:-text-embedding-mxbai-embed-large-v1}"
RERANK_MODEL_ID="${RERANK_MODEL_ID:-Qwen/Qwen3-Reranker-0.6B}"
RERANK_MODEL_NAME="${RERANK_MODEL_NAME:-qwen3-reranker-0.6b}"
EMBED_BATCH_SIZE="${EMBED_BATCH_SIZE:-8}"
RERANK_BATCH_SIZE="${RERANK_BATCH_SIZE:-2}"
ENGINE="${INFINITY_ENGINE:-optimum}"
DEVICE="${INFINITY_DEVICE:-cpu}"

ARGS="v2 \
  --host 0.0.0.0 \
  --port ${PORT} \
  --engine ${ENGINE} \
  --device ${DEVICE} \
  --model-id ${EMBED_MODEL_ID} \
  --served-model-name ${EMBED_MODEL_NAME} \
  --batch-size ${EMBED_BATCH_SIZE} \
  --engine ${ENGINE} \
  --device ${DEVICE} \
  --model-id ${RERANK_MODEL_ID} \
  --served-model-name ${RERANK_MODEL_NAME} \
  --batch-size ${RERANK_BATCH_SIZE}"

if [ -n "$API_KEY" ]; then
  ARGS="$ARGS --api-key ${API_KEY}"
fi

echo "[start] infinity on :${PORT}"
echo "[start] embedding=${EMBED_MODEL_ID} as ${EMBED_MODEL_NAME}"
echo "[start] reranker=${RERANK_MODEL_ID} as ${RERANK_MODEL_NAME}"

eval exec infinity_emb ${ARGS}
