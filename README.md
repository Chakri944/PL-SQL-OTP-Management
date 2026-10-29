# PL/SQL OTP Management

A Oracle PL/SQL project that demonstrates how stored procedures can generate a one-time password (OTP), save it in a database table, and validate it before its expiry time.

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
```

Save the relevant SQL statements in the files above as you organise the repository.

## Database setup

Run these scripts in an Oracle database schema where you have permission to create tables and procedures. i have practised using [Oracle FreeSQL](https://freesql.com/) 

### 1. Create the table

```sql
create table otp_table(
    phone_num NUMBER(10),
    otp number(6),
    otp_gen_time TIMESTAMP,
    otp_ent_time TIMESTAMP
)
```

### 2. Create the OTP generator

```sql
create or replace procedure otp_generator(
    p_number in number,
    p_otp out number
)
As 
begin 
    select trunc(dbms_random.value(100000,1000000)) into p_otp from dual;
    insert into otp_table(phone_num,otp,otp_gen_time,otp_ent_time)
    values(
            p_number,
            p_otp,
            sysdate,
            sysdate+(1/(24*60))
        );
end;
```

### 3. Create the OTP validator

```sql
create or replace procedure otp_validator(
    p_number in number,
    p_otp in number,
    p_message out varchar
) as
l_cnt number;
begin 
    select count(*) into l_cnt from otp_table
    where PHONE_NUM = p_number and 
    otp=p_otp and
    sysdate<=otp_ent_time;

    if l_cnt = 1 then
    p_message := 'Your otp is validated';
    else 
    p_message := 'Your otp is invalid';
    end if;
end;
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

```sql
DECLARE
    v_message VARCHAR2(100);
BEGIN
    otp_validator(9000000001, 123456, v_message);
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/
```

Replace `123456` with the generated OTP when testing a successful validation.

### 5. Inspect the table

```sql
SELECT phone_num, otp, otp_gen_time, otp_ent_time
FROM otp_table;
```

## How it works

1. The caller provides a phone number to `otp_generator`.
2. The generator produces a six-digit number and returns it through `p_otp`.
3. The generator inserts the OTP and its generation and expiry timestamps into `otp_table`.
4. The caller supplies the phone number and OTP to `otp_validator`.
5. The validator checks the matching record and confirms that its expiry timestamp has not passed.
6. The procedure returns a text message through `p_message`.

## Learning outcomes

By completing this project, I practised:

- Creating and executing stored procedures
- Using `IN` and `OUT` parameters
- Declaring variables and handling returned values
- Using SQL statements inside PL/SQL
- Working with timestamps and expiry checks
- Applying conditional logic to validation results
- Testing database code with different inputs

## Planned Future improvements

- Add a used-status column and prevent OTP reuse.
- Validate only the latest OTP issued for each phone number.
- Add an attempt counter and validation-attempt limits.
- Improve error handling and transaction management.
- Add repeatable test cases for valid, invalid, expired, and reused OTPs.
- Review secure OTP generation and storage approaches before considering any production use.


**Author:** Sri Chakradhar Reddy  
**Purpose:** PL/SQL learning and portfolio project
