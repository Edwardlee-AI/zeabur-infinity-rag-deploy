#!/bin/sh
set -eu

PORT="${PORT:-1234}"
API_KEY="${INFINITY_API_KEY:-}"
EMBED_MODEL_ID="${EMBED_MODEL_ID:-BAAI/bge-large-en-v1.5}"
EMBED_MODEL_NAME="${EMBED_MODEL_NAME:-text-embedding-bge-large-en-v1.5}"
RERANK_MODEL_ID="${RERANK_MODEL_ID:-BAAI/bge-reranker-base}"
RERANK_MODEL_NAME="${RERANK_MODEL_NAME:-bge-reranker-base}"
EMBED_BATCH_SIZE="${EMBED_BATCH_SIZE:-4}"
RERANK_BATCH_SIZE="${RERANK_BATCH_SIZE:-1}"
ENGINE="${INFINITY_ENGINE:-torch}"
DEVICE="${INFINITY_DEVICE:-cpu}"
MODEL_WARMUP="${INFINITY_MODEL_WARMUP:-false}"
COMPILE="${INFINITY_COMPILE:-false}"
BETTERTRANSFORMER="${INFINITY_BETTERTRANSFORMER:-false}"

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

if [ "$MODEL_WARMUP" = "true" ]; then
  ARGS="$ARGS --model-warmup"
else
  ARGS="$ARGS --no-model-warmup"
fi

if [ "$COMPILE" = "true" ]; then
  ARGS="$ARGS --compile"
else
  ARGS="$ARGS --no-compile"
fi

if [ "$BETTERTRANSFORMER" = "true" ]; then
  ARGS="$ARGS --bettertransformer"
else
  ARGS="$ARGS --no-bettertransformer"
fi

echo "[start] infinity on :${PORT}"
echo "[start] engine=${ENGINE} device=${DEVICE}"
echo "[start] embedding=${EMBED_MODEL_ID} as ${EMBED_MODEL_NAME} batch=${EMBED_BATCH_SIZE}"
echo "[start] reranker=${RERANK_MODEL_ID} as ${RERANK_MODEL_NAME} batch=${RERANK_BATCH_SIZE}"
echo "[start] model_warmup=${MODEL_WARMUP} compile=${COMPILE} bettertransformer=${BETTERTRANSFORMER}"

exec sh -c "infinity_emb ${ARGS}"
