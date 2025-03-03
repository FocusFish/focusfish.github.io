FROM squidfunk/mkdocs-material:9.6.7

COPY start.sh /usr/local/bin/

COPY requirements.txt .

RUN pip install -r requirements.txt

# Start development server by default
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/start.sh"]
CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:8000"]

