DECLARE
otp number;
BEGIN
    OTP_GENERATOR(1234556771,otp);
    dbms_output.PUT_LINE(otp);
end;

declare
valid_msg varchar;
BEGIN
    OTP_VALIDATOR(1234556771,167809,valid_msg);
    dbms_output.PUT_LINE(valid_msg);
end;