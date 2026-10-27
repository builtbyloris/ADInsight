# Data dictionary and analytical semantics

| Field | Definition / caution |
|---|---|
| `retailer`, `retailer_id` | Reporting business partner and supplied ID; not a customer ID |
| `invoice_date` | Recorded date; not a unique order |
| `region`, `state`, `city` | Recorded selling location, not customer residence |
| `product` | Six source product labels |
| `price_per_unit` | Reported price per unit in USD |
| `units_sold` | Quantity in the record |
| `total_sales` | **Recomputed** price × units; raw source contains 3,886 tenfold disagreements |
| `operating_margin` | Input source ratio; not audited cost data |
| `operating_profit` | **Recomputed** sales × source operating margin |
| `sales_method` | Online / Outlet / In-store; **not** a payment method |
| `year`, `month_number`, `year_month`, `weekday_number`, `is_weekend`, `season_it` | Derived time features |
| `product_gender` | Men's / Women's product **target**, not customer sex |
| `product_category` | Footwear / Apparel, derived from product string |

**Data grain:** source sales row. Do not derive AOV, customers, order count, repeat purchase rate or conversion.

**Weighted margin:** `SUM(operating_profit)/SUM(total_sales)`; not the mean of source record margins. **All USD results use recomputed values, not raw spreadsheet totals.**
