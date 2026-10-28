CREATE TABLE address (
    street VARCHAR(50) PRIMARY KEY,
    city VARCHAR(30) NOT NULL, 
    state VARCHAR(2) NOT NULL, 
    zipcode INTEGER NOT NULL
);

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY, 
    category_name VARCHAR(25) NOT NULL UNIQUE
);

CREATE TABLE brands (
    brand_id INTEGER PRIMARY KEY, 
    brand_name VARCHAR(25) NOT NULL UNIQUE
);

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY, 
    first_name VARCHAR(30) NOT NULL, 
    last_name VARCHAR(30) NOT NULL,
    phone VARCHAR(15), 
    email VARCHAR(50) NOT NULL,
    street VARCHAR(50) NOT NULL, 
    FOREIGN KEY(street) REFERENCES address(street)
);

CREATE TABLE stores (
    store_id INTEGER PRIMARY KEY, 
    store_name VARCHAR(30) NOT NULL UNIQUE, 
    phone VARCHAR(15), 
    email VARCHAR(50) NOT NULL,
    street VARCHAR(50) NOT NULL,
    FOREIGN KEY (street) REFERENCES address (street)
);

CREATE TABLE staffs (
    staff_id INTEGER PRIMARY KEY, 
    first_name VARCHAR(30) NOT NULL, 
    last_name VARCHAR(30) NOT NULL, 
    email VARCHAR(75) NOT NULL, 
    phone VARCHAR(15) NOT NULL, 
    active INTEGER NOT NULL, 
    store_id INTEGER NOT NULL, 
    manager_id INTEGER, 
    FOREIGN KEY(store_id) REFERENCES stores(store_id),
    FOREIGN KEY(manager_id) REFERENCES staffs(staff_id),
    CONSTRAINT UC_staff UNIQUE (email, phone)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY, 
    customer_id INTEGER NOT NULL, 
    order_status INTEGER NOT NULL, 
    order_date DATE NOT NULL, 
    required_date DATE NOT NULL, 
    shipped_date DATE,
    staff_id INTEGER NOT NULL,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY(staff_id) REFERENCES staffs(staff_id)
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY, 
    product_name VARCHAR(100) NOT NULL, 
    brand_id INTEGER NOT NULL, 
    category_id INTEGER NOT NULL, 
    model_year INTEGER NOT NULL, 
    list_price FLOAT(2) NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id), 
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE order_items (
    order_id INTEGER,
    product_id INTEGER, 
    quantity INTEGER NOT NULL, 
    discount NUMERIC NOT NULL,
    PRIMARY KEY(order_id, product_id),
    FOREIGN KEY(order_id) REFERENCES orders(order_id), 
    FOREIGN KEY(product_id) REFERENCES products(product_id)
);

CREATE TABLE stocks (
    store_id INTEGER,
    product_id INTEGER,
    quantity INTEGER NOT NULL,
    PRIMARY KEY(store_id, product_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id), 
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
