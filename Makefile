py-build: py-base/conda-linux-64.lock
	docker compose stop py
	docker compose build py

py-base/conda-linux-64.lock: py-base/environment.yml
	conda-lock --kind explicit --platform linux-64 -f py-base/environment.yml
	mv conda-linux-64.lock py-base/conda-linux-64.lock

py-lock:
	conda-lock --kind explicit --platform linux-64 -f py-base/environment.yml
	mv conda-linux-64.lock py-base/conda-linux-64.lock

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
