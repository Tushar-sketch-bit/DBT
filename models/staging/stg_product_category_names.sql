select
    product_category_name,
    product_category_name_english
from {{ source('olist','product_category_names') }};
