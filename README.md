# Optics SI Cloud Tools

<a href="https://michaelakridge-noaa.github.io/optics-si-cloud-tools/" target="_blank"><img src="./docs/logo/optics_si_logo_v1.png" align="right" alt="logo" height="250"/></a>

Optics SI cloud tools repository is to support data science workflows, cloud deployment, documentation, and reproducible research using cloud workstations and resources.

### Data Labeling & Data Management Tools (Related)

- **CAT (Coral Annotation Tool):** https://github.com/MichaelAkridge-NOAA/cat
	- Install:
		```bash
		pip install coral-annotation-tool
		cat
		```
	- Default URL: `http://localhost:8000`

- **Njobvu-AI Docker:** https://github.com/MichaelAkridge-NOAA/njobvu-ai-docker
	- Install/Run:
		```bash
		docker run -p 8080:8080 michaelakridge326/njobvu-ai
		```
	- Default URL: `http://localhost:8080`

- **JetStream:** https://github.com/MichaelAkridge-NOAA/jetstream/tree/main
	- Install + auth + run:
		```bash
		git clone https://github.com/MichaelAkridge-NOAA/jetstream.git
		cd jetstream
		pip install -r requirements.txt
		gcloud auth login --no-launch-browser
		gcloud auth application-default login --no-launch-browser
		python -m uvicorn jetstream_api.main:app --reload
		```
	- Default URL: `http://localhost:8000`

### Quick Start - Cloud Workstation Setup
- **[Visit this Link for the Full Setup Guides & Codelabs](https://michaelakridge-noaa.github.io/optics-si-cloud-tools/)**

### Main Folders
- **cloud/**: Cloud deployment resources (e.g., Terraform, AWS, Azure, GCP configs).
- **scripts/**: Setup scripts for Cloud Workstations ([see README](./scripts/README.md)).
- **notebooks/**: Jupyter notebooks for exploration, analysis, and prototyping.
- **documents/**: Project documentation, reports, and references.
- **data/**: Example datasets, data schemas, and data management scripts.
- **models/**: Pretrained models, model checkpoints, and training logs.
- **codelabs/**: Source markdown for step-by-step tutorials.
- **docs/**: GitHub Pages site with interactive codelabs.

----------
#### Disclaimer
This repository is a scientific product and is not official communication of the National Oceanic and Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project content is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub project will be governed by all applicable Federal law. Any reference to specific commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply their endorsement, recommendation or favoring by the Department of Commerce. The Department of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to imply endorsement of any commercial product or activity by DOC or the United States Government.

#### License
- Details in the [LICENSE.md](./LICENSE.md) file.
