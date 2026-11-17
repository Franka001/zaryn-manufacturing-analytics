# Manufacturing Operations Analytics
### A Zaryn Data Engineering Portfolio Showcase

Microsoft-focused data engineering for manufacturing reporting, with an existing SQL starting point and a planned Fabric analytics workflow.

> Status: In-progress portfolio project. Database scripts and project folders are present. Their presence does not establish successful execution, a deployed Fabric solution, or a completed Power BI report. End-to-end validation and measured results are not documented in this overview. This repository is not presented as a client deployment.

## Business Problem

Manufacturing teams need consistent operational reporting without repeatedly combining production, inventory, and other business data manually. This showcase is intended to demonstrate how source data can be organized into a documented analytical workflow.

## Intended Business Questions

- What inventory measures can be derived consistently from the available source data?
- How can production, downtime, and scrap reporting be added with explicit metric definitions?
- How can source records be traced through transformations into analytical outputs?

These are project goals; availability of each answer depends on implemented and validated source data and transformations.

## Existing Repository Assets

| Asset | Location |
|---|---|
| Database creation script | [01_create_database.sql](database/01_create_database.sql) |
| Table creation script | [02_create_tables.sql](database/02_create_tables.sql) |
| Sample data script | [03_insert_sample_data.sql](database/03_insert_sample_data.sql) |
| Inventory turnover SQL | [04_inventory_turnover.sql](database/04_inventory_turnover.sql) |
| Database documentation | [database/README.md](database/README.md) |
| Architecture folder | [architecture](architecture/) |
| Data folder | [data](data/) |
| Fabric project folders | [fabric](fabric/) |
| Python notebook folder | [python_notebooks](python_notebooks/) |
| Power BI project folders | [powerbi](powerbi/) |

This inventory identifies available files and folders, not tested functionality. Consult individual artifacts for their contents and requirements.

## Proposed Target Architecture

Source SQL Server tables and sample extracts → Fabric Data Factory ingestion → Bronze lakehouse → Silver transformations using SQL/PySpark → Gold analytical tables → Power BI

This is a proposed target design, not a claim that the full workflow is deployed. Python may support sample-data preparation and validation. Power Automate or Azure Logic Apps may be evaluated for a scoped exception workflow; neither is required merely to display the technology stack.

## Implementation and Validation Roadmap

- [x] Establish the repository structure and add initial database scripts
- [ ] Verify database setup in an isolated development environment
- [ ] Document source schemas, data provenance, and synthetic-data assumptions
- [ ] Review metric definitions, including inventory turnover inputs and reporting periods
- [ ] Implement and document ingestion and transformation steps
- [ ] Add key, null, duplicate, and source-to-target reconciliation checks
- [ ] Demonstrate safe reruns and recovery from a failed batch
- [ ] Build and validate the Power BI model and report
- [ ] Publish actual architecture diagrams, screenshots, and test evidence
- [ ] Document deployment, access, cost assumptions, and operating procedures

## Setup and Execution Status

Start by reviewing the [database documentation](database/README.md) and SQL scripts. Use an isolated development environment and inspect database names and object-creation statements before running anything. The numbered SQL filenames indicate an intended sequence, but a verified end-to-end setup procedure is still pending. No deployment or execution was performed as part of this documentation update.

## Reporting and Metric Rules

Each published metric should specify its source, grain, time window, units, formula, exclusions, and treatment of missing data. Production, downtime, scrap, and inventory measures must not be represented as validated until their source fields and calculations have been checked. No financial savings or performance improvements are claimed.

## Related Portfolio Showcases

| Project | Focus | Current scope |
|---|---|---|
| [Wholesale Inventory & Fulfillment Analytics](https://github.com/Franka001/zaryn-distribution-inventory-analytics) | Inventory visibility, outstanding demand, and fulfillment metrics | Design-stage documentation |
| [SQL Server & SSIS Modernization Blueprint](https://github.com/Franka001/zaryn-ssis-modernization) | Assessment, reconciliation, and phased modernization | Design-stage documentation |

## Discuss a Similar Project

Zaryn Data Engineering provides Microsoft-focused data engineering services for manufacturing and wholesale distribution.

Email: [admin@zaryndata.onmicrosoft.com](mailto:admin@zaryndata.onmicrosoft.com)

Share your business challenge, source systems, and desired timeline at a high level. Do not send credentials or confidential datasets in an initial inquiry.
