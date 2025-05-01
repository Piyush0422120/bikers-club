# Ok so new SQL program- connected to python
CREATE DATABASE Bikers_club;

# ADDING PRIMARY KEYS

#  brands table
ALTER TABLE brands
ADD PRIMARY KEY (brand_id);

# categories table
ALTER TABLE categories
ADD PRIMARY KEY (category_id);

# customers table
ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

# orders table
ALTER TABLE orders
ADD PRIMARY KEY (order_id);

# products
ALTER TABLE products
ADD PRIMARY KEY (product_id);

# staffs
ALTER TABLE staffs
ADD PRIMARY KEY (staff_id);

# stores
ALTER TABLE stores
ADD PRIMARY KEY (store_id);
