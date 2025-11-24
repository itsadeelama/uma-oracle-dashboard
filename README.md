# UMA Optimistic Oracle v3 — Data Analysis & Dashboard (Superset)

**Disclaimer:**  
This project is not intended for commercial use.  
It was completed in **≈2.5 hours** purely as a demonstration of my ability to:
- work with blockchain/DeFi data,
- perform analytical SQL modeling,
- build dashboards,
- and communicate insights effectively.

All results depend entirely on the data available through **Dune Analytics**.  
Accuracy is limited by the completeness and correctness of Dune’s decoded datasets.

---

## 📌 Overview

This project analyzes the **UMA Optimistic Oracle v3** dataset to explore trends in:
- assertion volume,
- settlement performance,
- dispute behavior,
- per-chain usage,
- and dominance over time.

All visuals were created using a **locally hosted Superset instance** connected to a **local PostgreSQL database** populated with data extracted via the **Dune API**.

The purpose of this repository is to demonstrate my ability to:
- locate and clean blockchain data,
- engineer analytical datasets,
- design meaningful metrics,
- write complex SQL for time-series and dominance calculations,
- and present insights in a structured dashboard format.

---

## 🛠️ Data Source & Extraction

### Attempted UMA subgraph — failed  
The UMA documentation references a subgraph endpoint on **The Graph Explorer**, but the link currently returns **404**.  
Due to the unavailability of the intended subgraph, I switched to using **Dune Analytics**.

### Dune dataset used  
Inside Dune, under the **Optimist UMA Project (Multichain)** decoded project, there is a dataset titled:

> **Optimistic Oracle Version 3**

This includes decoded assertion/dispute/settlement data across multiple chains.

### Query + API Ingestion Workflow
1. Wrote a custom SQL query inside Dune to extract:
   - made_time  
   - disputed_time  
   - settled_time  
   - chain  
   - identifier  
   - claim  
   - bond  
   - resolution flags  
   - and other relevant fields  
2. Queried the Dune API to retrieve the full dataset programmatically.  
3. Ingested the results into a **local PostgreSQL** database.

---

## 🗄️ Local Environment Setup

### PostgreSQL
A local Postgres instance was used to store and transform the dataset.  
This allowed:
- faster iteration,
- more advanced SQL capabilities,
- and controlled time-series modeling.

### Superset (Docker)
A local Superset instance was provisioned via Docker:
- PostgreSQL added as a data source
- SQL Lab used to model metrics
- Dashboards built from transformed tables and virtual datasets

---

## 📊 Analytical Work

### Key metrics and models created:
- Daily assertions  
- Daily disputes  
- Daily settlements  
- Month-over-month activity  
- Chain-level usage trends  
- **Zero-filled time-series matrix** (month × chain)  
- **Chain dominance percentage over time**  
- Rolling 30-day settlement delay  
- Settlement delay distributions  
- Chain × year hierarchical breakdown (Sunburst)

### SQL techniques used:
- `generate_series` for calendar tables  
- Cross joins to build full month–chain matrices  
- `coalesce` zero-filling  
- Window functions (`OVER`, rolling windows)  
- Time truncation (`date_trunc`)  
- Proportional dominance calculations  
- Grouping minor chains into “others” bucket  
- Categorical and time-series transformations

---

## 📈 Dashboard

Superset was used to design a series of charts, including:
- line charts
- time-series area charts (100% stacked)
- bar charts
- sunburst hierarchy charts
- KPIs and summary metrics

Screenshots of the final dashboard visuals are included in the `/images` directory.

---

## 📁 Repository Structure
/images/ # dashboard screenshots

README.md # project documentation

## 🎯 Purpose of This Project

This work demonstrates practical skill in:
- SQL modeling  
- data cleaning and engineering  
- analytical reasoning  
- on-chain analytics  
- dashboard creation  
- and storytelling with data  

The goal is to showcase the ability to take a real-world dataset, transform it into meaningful insight, and present it clearly and professionally.
