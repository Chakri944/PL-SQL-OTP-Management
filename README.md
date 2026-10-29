# PL/SQL OTP Management

A beginner-friendly Oracle PL/SQL project that demonstrates how stored procedures can generate a one-time password (OTP), save it in a database table, and validate it before its expiry time.

> **Learning project only:** This implementation is for practising SQL and PL/SQL. It is **not suitable for production authentication**. See [Limitations and security notes](#limitations-and-security-notes) before using it beyond a learning environment.

## Features

- Generate a six-digit numeric OTP using `DBMS_RANDOM`.
- Use an `OUT` parameter to return the generated OTP from a procedure.
- Store the phone number, OTP, generation timestamp, and expiry timestamp in an Oracle table.
- Validate an OTP against a phone number and its expiry time.
- Return a validation message through an `OUT` parameter.
- Practise stored procedures, `IN` and `OUT` parameters, variables, `INSERT`, `SELECT`, and conditional logic.

## Technologies

- Oracle Database
- SQL and PL/SQL
- `DBMS_RANDOM`
- `DBMS_OUTPUT`

## Project structure

```text
plsql-otp-management/
├── README.md
├── sql/
│   ├── 01_create_table.sql
│   ├── 02_otp_generator.sql
│   ├── 03_otp_validator.sql
│   └── 04_test_procedures.sql
└── docs/
    └── screenshots/
```

Save the relevant SQL statements in the files above as you organise the repository.

## Database setup

Run these scripts in an Oracle database schema where you have permission to create tables and procedures. You can practise using [Oracle FreeSQL](https://freesql.com/) or [Oracle SQL Developer](https://www.oracle.com/database/sqldeveloper/).

### 1. Create the table

```sql
CREATE TABLE otp_table (
    phone_num    NUMBER(10),
    otp          NUMBER(6),
    otp_gen_time TIMESTAMP,
    otp_ent_time TIMESTAMP
);
```

### 2. Create the OTP generator

```sql
CREATE OR REPLACE PROCEDURE otp_generator (
    p_number IN NUMBER,
    p_otp    OUT NUMBER
)
AS
BEGIN
    SELECT TRUNC(DBMS_RANDOM.VALUE(100000, 999999))
    INTO p_otp
    FROM dual;

    INSERT INTO otp_table (
        phone_num,
        otp,
        otp_gen_time,
        otp_ent_time
    )
    VALUES (
        p_number,
        p_otp,
        SYSTIMESTAMP,
        SYSTIMESTAMP + INTERVAL '1' MINUTE
    );
END;
/
```

This version keeps the OTP valid for one minute. The `DBMS_RANDOM.VALUE` upper bound is exclusive, so this expression generates values from `100000` through `999998`.

### 3. Create the OTP validator

```sql
CREATE OR REPLACE PROCEDURE otp_validator (
    p_number  IN NUMBER,
    p_otp     IN NUMBER,
    p_message OUT VARCHAR2
)
AS
    l_cnt NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO l_cnt
    FROM otp_table
    WHERE phone_num = p_number
      AND otp = p_otp
      AND SYSTIMESTAMP <= otp_ent_time;

    IF l_cnt = 1 THEN
        p_message := 'Your OTP is validated';
    ELSE
        p_message := 'Your OTP is invalid';
    END IF;
END;
/
```

The validator checks whether exactly one matching, unexpired row exists for the supplied phone number and OTP.

### 4. Test the procedures

Enable `DBMS_OUTPUT` in your SQL client, then run:

```sql
DECLARE
    v_otp NUMBER;
BEGIN
    otp_generator(9000000001, v_otp);
    DBMS_OUTPUT.PUT_LINE('Generated OTP: ' || v_otp);
END;
/
```

Use the OTP shown in the output to test validation. Replace the example value with a test phone number that you control only in a private test environment; do not publish real phone numbers or generated OTPs.

```sql
DECLARE
    v_message VARCHAR2(100);
BEGIN
    otp_validator(9000000001, 123456, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/
```

Replace `123456` with the generated OTP when testing a successful validation. An arbitrary or expired OTP should return the invalid message.

### 5. Inspect the table

```sql
SELECT phone_num, otp, otp_gen_time, otp_ent_time
FROM otp_table;
```

**Note:** The table stores OTPs in plain text, so use only dummy data in this learning project.

## How it works

1. The caller provides a phone number to `otp_generator`.
2. The generator produces a six-digit number and returns it through `p_otp`.
3. The generator inserts the OTP and its generation and expiry timestamps into `otp_table`.
4. The caller supplies the phone number and OTP to `otp_validator`.
5. The validator checks the matching record and confirms that its expiry timestamp has not passed.
6. The procedure returns a text message through `p_message`.

## Limitations and security notes

This project demonstrates PL/SQL concepts, not a secure OTP service. The current implementation:

- Uses `DBMS_RANDOM`, which is **not intended for cryptographically secure OTP generation**.
- Stores OTP values in plain text.
- Does not mark an OTP as used after successful validation, so a matching OTP can be reused before expiry.
- Does not restrict validation to only the latest OTP for a phone number.
- Does not limit failed validation attempts or implement rate limiting.
- Uses `NUMBER(10)` for phone numbers; a `VARCHAR2` column is usually more appropriate for phone numbers because they are identifiers and can include leading zeros or a country code.
- Uses a simple count-based validation query and does not handle concurrency or authentication workflow concerns.

Do not use this implementation to protect real user accounts or sensitive information. A production design needs a cryptographically secure random generator, careful OTP storage and expiry handling, one-time use, attempt limits, rate limiting, and appropriate transaction and application-layer controls.

## Learning outcomes

By completing this project, I practised:

- Creating and executing stored procedures
- Using `IN` and `OUT` parameters
- Declaring variables and handling returned values
- Using SQL statements inside PL/SQL
- Working with timestamps and expiry checks
- Applying conditional logic to validation results
- Testing database code with different inputs

## Planned improvements

- Add a used-status column and prevent OTP reuse.
- Validate only the latest OTP issued for each phone number.
- Add an attempt counter and validation-attempt limits.
- Improve error handling and transaction management.
- Add repeatable test cases for valid, invalid, expired, and reused OTPs.
- Review secure OTP generation and storage approaches before considering any production use.

## References

- [Oracle FreeSQL](https://freesql.com/)
- [Oracle SQL Developer](https://www.oracle.com/database/sqldeveloper/)
- [Oracle `DBMS_RANDOM` documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/arpls/DBMS_RANDOM.html)

---

**Author:** Sri Chakradhar Reddy  
**Purpose:** PL/SQL learning and portfolio project
