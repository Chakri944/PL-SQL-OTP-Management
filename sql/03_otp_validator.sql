create or replace procedure otp_validator(
    p_number in number,
    p_otp in number,
    p_message out VARCHAR
) As
l_cnt number;
begin 
    select count(*) into l_cnt from OTP_TABLE
    where PHONE_NUM = p_number and 
    OTP=p_otp and
    sysdate<=OTP_ENT_TIME;

    if l_cnt = 1 then
    p_message := 'Your otp is validated';
    else 
    p_message := 'Your otp is invalid';
    end if;
end;