> **DISCLAIMER:** This project uses [northwind](https://docs.yugabyte.com/preview/sample-data/northwind/) as source data, which is a publicly avaiable dataset.  
# Project Objectives
This project aims to craft a modern data warehouse solution that:
- Tracks orders by product, cateory and location.  
- Tracks product price chaneges using Slowly Chaning Dimension (SCD) type 2.
- Tracks Inventory data to conduct Safety stock analysis in the future.
# Business Logic
- `Cutomer names`, `products name`, `cateories`, `location data` are consistent a cross all sources.



# Data Lineage
![DAG](./readme_assets/dbt-dag.png)



# ERD
```mermaid
erDiagram
    fact_inventory ||--o{ dim_products: ""
    fact_inventory ||--o{ dim_suppliers: ""
    fact_orders ||--o{ dim_location: ""
    fact_orders ||--o{ dim_products: ""
    
    fact_orders {
        transaction_id	text       PK
        order_id	    integer     
        order_date	    date
        required_date	date
        shipped_date	date
        location_sk	    text        FK
        product_sk	    text        FK
        unit_price	    numeric
        quantity	    integer
        discount	    numeric
    }

    fact_inventory {
        product_sk	    text        FK
        supplier_sk	    text        FK
        units_in_stock	integer
        units_on_order	integer
        reorder_level	integer
        record_id	    text        PK
        updated_at	    timestamp
    }

    dim_products {
        product_sk	        text        PK
        product_id	        integer     
        product_name	    text
        category_name	    charactervarying
        unit_price	        numeric
        quantity_per_unit	charactervarying
        start_date	        date
        end_date	        date
        is_active	        boolean
        valid_days	        integer
    }

    dim_location {
        location_sk	    text    PK
        address	        text
        city	        text
        region	        text
        postal_code	    text
        country	        text
    }


    dim_suppliers{
        supplier_sk     text                PK
        company_name    text                
        contact_name    text                
        contact_title   text                
        location_sk     text                
        phone       	charactervarying                
        fax     	    charactervarying                
        homepage        text                
    }
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
