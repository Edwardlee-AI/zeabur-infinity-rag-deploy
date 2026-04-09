FROM michaelf34/infinity:latest-cpu

ENV HF_HOME=/app/.cache/huggingface
ENV PORT=1234

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 1234

CMD ["/app/start.sh"]
