FROM michaelf34/infinity:latest-cpu

# Qwen3-Embedding requires transformers >= 4.51 (qwen3 arch not in image's bundled version)
RUN pip install --no-cache-dir --upgrade "transformers>=4.51"

ENV HF_HOME=/app/.cache/huggingface
ENV PORT=1234
ENV INFINITY_ENGINE=torch
ENV INFINITY_DEVICE=cpu
ENV INFINITY_MODEL_WARMUP=false
ENV INFINITY_COMPILE=false
ENV INFINITY_BETTERTRANSFORMER=false
ENV EMBED_BATCH_SIZE=4
ENV RERANK_BATCH_SIZE=1

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 1234

ENTRYPOINT ["/app/start.sh"]
