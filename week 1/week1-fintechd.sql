create database fintechdb;
use fintechdb;
CREATE TABLE customer (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
    name VARCHAR(100)
);
select * from customer;
INSERT INTO customer (name) VALUES ('Alice');
INSERT INTO customer (name) VALUES ('Bob');
INSERT INTO customer (name) VALUES ('Charlie');

CREATE TABLE transaction_ (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),

    from_customer_id CHAR(36) NOT NULL,
    to_customer_id   CHAR(36) NOT NULL,

    type ENUM('credit', 'debit') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

   
        FOREIGN KEY (from_customer_id)
        REFERENCES customer(id),

   
        FOREIGN KEY (to_customer_id)
        REFERENCES customer(id)
);
select * from transaction_;
INSERT INTO transaction_ (
    from_customer_id,
    to_customer_id,
    type,
    amount
) VALUES (
    '23e83a09-00e1-11f1-9c31-c01803c11826',
    '27b0309a-00e1-11f1-9c31-c01803c11826',
    'debit',
    150.00
);
INSERT INTO transaction_ (
    from_customer_id,
    to_customer_id,
    type,
    amount
) VALUES (
    '27b0309a-00e1-11f1-9c31-c01803c11826',
    '2a952668-00e1-11f1-9c31-c01803c11826',
    'credit',
    150.00
);

INSERT INTO transaction_ (
    from_customer_id,
    to_customer_id,
    type,
    amount
) VALUES (
    '2a952668-00e1-11f1-9c31-c01803c11826',
    '23e83a09-00e1-11f1-9c31-c01803c11826',
    'debit',
    75.50
);
CREATE TABLE credit_history (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),

    customer_id CHAR(36) NOT NULL,

    credit_transactions JSON NOT NULL,

        FOREIGN KEY (customer_id)
        REFERENCES customer(id)
);


INSERT INTO credit_history (
    customer_id,
    credit_transactions
)
VALUES (
    '2a952668-00e1-11f1-9c31-c01803c11826',
    (
        SELECT JSON_ARRAYAGG(id)
        FROM transaction_
        WHERE
            to_customer_id = '2a952668-00e1-11f1-9c31-c01803c11826'
            AND type = 'credit'
    )
);
SELECT
    customer_id,
    JSON_PRETTY(credit_transactions)
FROM credit_history;



CREATE TABLE customer_review (
    id CHAR(36) PRIMARY KEY DEFAULT (UUID()),

    customer_id CHAR(36) NOT NULL,
    transaction_id CHAR(36) NOT NULL,

    rating TINYINT NOT NULL,
    feedback VARCHAR(500),

   

   
        FOREIGN KEY (customer_id)
        REFERENCES customer(id)
        ON DELETE CASCADE,

   
        FOREIGN KEY (transaction_id)
        REFERENCES transaction_(id)
        ON DELETE CASCADE,

    CONSTRAINT chk_rating_range
        CHECK (rating BETWEEN 1 AND 5)
) ;

-- Bob reviews credit received from Alice
INSERT INTO customer_review (
    customer_id,
    transaction_id,
    rating,
    feedback
) VALUES (
    '27b0309a-00e1-11f1-9c31-c01803c11826',  -- Bob
    '87acd0bb-00e1-11f1-9c31-c01803c11826',  -- transaction ID (credit)
    5,
    'Received the payment quickly and smoothly.'
);



SELECT
    cr.id,
    c.name AS customer_name,
    t.id AS transaction_id,
    t.amount,
    cr.rating,
    cr.feedback
   
FROM customer_review cr
JOIN customer c ON c.id = cr.customer_id
JOIN transaction_ t ON t.id = cr.transaction_id;

