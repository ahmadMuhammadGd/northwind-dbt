> **DISCLAIMER:** This project uses [northwind](https://docs.yugabyte.com/preview/sample-data/northwind/) as a source data, which is a publicly avaiable dataset.  
# Project Objectives
This project aims to craft a modern data warehouse solution that:
- Tracks orders by product, cateory and location.  
- Tracks product price chaneges using Slowly Chaning Dimension (SCD) type 2.
- Tracks Inventory data to conduct Safety stock analysis in the future.
# Business Logic
- `Cutomer names`, `products name`, `cateories`, `location data` are consistent a cross all sources.
- It's planned to integrate more ddata sources in the future.
# Approach

``` mermaid
flowchart LR;
A[Source 1]
B[Source 2]
C[Staing table orders]
D[Join operation]
F[Orders fact]
G[Staging table products]

A -- "store 'source 1' in data_src" --> C
B -- "store 'source 2' in data_src" --> C

A -- "store 'source 1' in data_src" --> G
B -- "store 'source 2' in data_src" --> G


C -- "product_id AND data_src" --> D
G -- "product_id AND data_src" --> D


D --"Replace source foreign keys with new pproducts surrogate keys"--> F

```

- Adding addition column in all staing tables called `data_src` to store source's name
- Assuming that `cutomer name`, `product name`, `cateorie`, `location data` doesn't cause conflicts, it's used as [Surrogate key](https://en.wikipedia.org/wiki/Surrogate_key) to replace **source's foreign keys**. `Surrogate key` can combine one or more **concatenated and catsted as text** columns using [MD5 hashing](https://en.wikipedia.org/wiki/MD5).
- `Source's foreign key` and `data_src` are used as [composite key](https://en.wikipedia.org/wiki/Composite_key) to replace `source's foreign key` with new `surrogate key`..
- If possible, the below logic can be used to generate `surrogate keys` instead of joining. 
## Surrogate keys logic
| Surrogate key | Logic |
|---------------|-------|
| **category_sk** | MD5 Hash of **cleaned** `category_name`|
| **product_sk**  | MD5 Hash of **cleaned** `product_name`|
| **supplier_sk** | MD5 Hash of **cleaned** `supplier_sk`|

********
# Data Lineage
![DAG](./readme_assets/dbt-dag(3).png)
# Limitations
## IO
`MD5` generates `128-bit digest` which utilises bigger `IO` compare to [`BIGINT`](https://www.postgresql.org/docs/current/datatype-numeric.html) `64-bits` type that has a range of `-9223372036854775808` to `+9223372036854775807` 

# ERD
```mermaid
erDiagram
    dim_product {
        TEXT product_SK PK
        TEXT product_name
        TEXT category_sk
        NUMERIC unit_price
        VARCAR quantity_per_unit
        BOOL discontinued
        TEXT dbt_scd_id
        TIMESTAMP dbt_updated_at
        TIMESTAMP dbt_valid_from
        TIMESTAMP dbt_valid_to
    }

    dim_supplier {
        TEXT supplier_sk PK
        TEXT company_name
        TEXT contact_name
        TEXT contact_title
        TEXT location_sk
        VARCHAR phone
        VARCHAR fax
        TEXT homepage
    }

    dim_location {
        TEXT location_sk PK
        VARCHAR address
        VARCHAR city
        VARCHAR region
        VARCHAR postal_code
        VARCHAR country
    }

    fact_orders {
        TEXT transaction_id PK
        INT order_id
        DATE order_date
        DATE required_date
        DATE shipped_date
        TEXT location_sk
        NUMERIC unit_price
        INT quantity
        NUMERIC discount
    }

    fact_inventory {
        TEXT product_SK PK
        TEXT supplier_sk
        INT units_in_stock
        INT units_on_order
        INT reorder_level
        TIMESTAMP record_id
        TIMESTAMP updated_at
    }

    dim_product ||--o{ fact_orders : ""
    dim_product ||--o{ fact_inventory : ""
    dim_supplier ||--o{ dim_product:""
    dim_location ||--o{ dim_supplier:""
    dim_location ||--o{ fact_orders:""
```
# dbt Model Structure
``` bash
> tree ./northwind/models 
./northwind/models
├── db_staging
│   ├── db_staging.yaml
│   ├── stg_categories.sql
│   ├── stg_inventory.sql
│   ├── stg_order_details.sql
│   ├── stg_orders.sql
│   ├── stg_products.sql
│   └── stg_suppliers.sql
├── groups.yml
├── marts
│   ├── dimensions
│   │   ├── dim_category.sql
│   │   ├── dimensions.yml
│   │   ├── dim_location.sql
│   │   ├── dim_products.sql
│   │   └── dim_suppliers.sql
│   ├── inventory
│   │   ├── fact_inventory.sql
│   │   └── inventory.yml
│   └── orders
│       ├── fact_orders.sql
│       └── orders.yaml
└── source.yml

5 directories, 18 files
```