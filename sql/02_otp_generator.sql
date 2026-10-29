create or replace procedure otp_generator(
    p_number IN number,
    p_otp out number
)As 
begin 
    select trunc(dbms_random.value(100000,1000000)) into p_otp from dual;
    insert into otp_table(phone_num,otp,otp_gen_time,otp_ent_time) values(p_number,p_otp,sysdate,sysdate+(1/(24*60)));
end;