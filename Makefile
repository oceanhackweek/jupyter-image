py-build:
	docker compose stop py
	docker compose build py

py-lab:
	docker compose up py

r-build: r/conda-linux-64.lock
	docker compose stop r
	docker compose build r

r/conda-linux-64.lock: r/environment.yml
	conda-lock --kind explicit --platform linux-64 -f r/environment.yml
	mv conda-linux-64.lock r/conda-linux-64.lock

r-lock:
	conda-lock --kind explicit --platform linux-64 -f r/environment.yml
	mv conda-linux-64.lock r/conda-linux-64.lock

r-lab:
	docker compose up r
