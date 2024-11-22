# Northwind-dbt 🔨



> **DISCLAIMER:** This project uses [northwind](https://docs.yugabyte.com/preview/sample-data/northwind/) as source data, which is a publicly avaiable dataset.  



# 🤓 What is special about this?

- **Unit tests 📑**: Quality `data tests`, and `unit tests` to simulate business scenarious.            

- **Data Tests 📑**: Simple, but save these errors in a seperate table to curate them later.

- **Models Versioning ✨**: Two versioned models, `stg_inventory` and `fact_inventory`.

- **CI/CD 👾**: Initialize test-environment, build models, run models in `incremental_mode`, run `data tests`, and run `unit tests` in isolated environment before merging into `main` branch - using `Github Actions`.

- **Enforced Schema ✊**: Prevents unexpected `data quality` issues caused by changes in the source schema.

- **Slowly Chaning Dimension (SCD) type 2 🐢**: Products SCD but with old way.




# 🤔 Project Objectives
This project aims to craft a modern data warehouse solution that:
- 🤖 Track `orders` by `product`, `cateory` and `location`.  
- 🤖 Track `product price chaneges effect on orders`.
- 🤖 Track `Inventory` data to conduct Safety stock analysis in the future.




# ERD

This is how I modeled the data—guided by **Ralph Kimball’s principles** in **The Data Warehouse Toolkit** 📖.


```mermaid
erDiagram
    fact_inventory ||--o{ dim_products: "stores"
    fact_inventory ||--o{ dim_suppliers: "supplied_by"
    fact_inventory ||--o{ dim_date: "recorded_at"
    fact_orders ||--o{ dim_location: "ordered_from"
    fact_orders ||--o{ dim_products: "ordered_what"
    fact_orders ||--o{ dim_date: "ordered_at"

    fact_orders {
        transaction_sk  text    PK
        order_sk        int
        order_id        int
        order_date      date
        required_date   date
        order_status    varchar
        shipped_date    date
        location_sk     text
        product_sk      text
        unit_price      numeric
        quantity        int
        discount        numeric
    }

    fact_inventory {
        record_id	    text        PK
        product_sk	    text        FK
        supplier_sk	    text        FK
        units_in_stock	integer
        units_on_order	integer
        reorder_level	integer
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
        supplier_sk     text     PK
        supplier_id     int
        company_name    text                
        contact_name    text                
        contact_title   text                
        location_sk     text                
        phone       	charactervarying                
        fax     	    charactervarying                
        homepage        text                
    }

    dim_date {
        date_day                        date    PK
        prior_date_day                  date
        next_date_day                   date
        prior_year_date_day             date
        prior_year_over_year_date_day   date
        day_of_week                     integer
        day_of_week_name                text
        day_of_week_name_short          text
        day_of_month                    int
        day_of_year                     int
        week_start_date                 date
        week_end_date                   date
        prior_year_week_start_date      date
        prior_year_week_end_date        date
        week_of_year                    integer
        iso_week_start_date             date
        iso_week_end_date               date
        prior_year_iso_week_start_date  date
        prior_year_iso_week_end_date    date
        iso_week_of_year                integer
        prior_year_week_of_year         integer
        prior_year_iso_week_of_year     integer
        month_of_year                   integer
        month_name                      text
        month_name_short                text
        month_start_date                date
        month_end_date                  date
        prior_year_month_start_date     date
        prior_year_month_end_date       date
        quarter_of_year                 integer
        quarter_start_date              date
        quarter_end_date                date
        year_number                     integer
        year_start_date                 date
        year_end_date                   date
    }
```



# 🤯 Data Lineage
> **🤸 Note** the two versions of `stg_inventory` and `fact_inventory`, `unit tests` are also included.                 
![DAG](./readme_assets/dbt-dag.png)
