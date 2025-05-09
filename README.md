# Data Model for Accurx: Product Usage Analyses

Objective:  create data models that are 
1. modular in design so can support one-off analytical queries as well as be used as building blocks for BI monitoring
2. logical for each business domain orientation, e.g. product vs user vs org
3. robust, easy to support and debug

DAG considerations:
- separate the models into different execution layers depending on transformation purpose
- 'src' aims to cast data types from raw and resolve any pipeline orchestration or source system naming inconsistencies but applies no analytical transformations
- 'staging' splits src tables into logical business domains and entities, eg. video & messaging are 2 separate products that can develp very different features & data structures going forward and applies deduplication where appropriate.  allows unstructured data to be easily surfaced in future feature developments
- 'mart' organises business entities into facts and dimensions using simple joins & normalises them as possible to avoid redundancy issues
- 'analyses' files provide example queries for downstream use cases, can be materialized as views for reusability or translated into semantic layer metrics for lineage and governance tracking

![mart.dim_org_feature_access lineage illustration](.\docs\dim_org_dag.jpg)

![mart.erd](.\docs\erd_accurx.jpg)

Notes:
- table and column documentation available in .yml files and assumes users can see them either in the warehouse or in dbt UI.  Other data cataloguing tools can be considered
- all .yml data_tests throughout the project play an important role in maintaining data integrity in each layer.  Job orchestration can be designed around these tests as a dependency for each layer
