entity flipflopd is
  port( 
    D, reset, clock, EN: in  bit;
    Q:                   out bit
  );
end flipflopd;

architecture behavior of flipflopd is
begin
  process (reset, clock)
  begin
    if reset='0' then
      Q <= '0';
    elsif clock'EVENT and clock='1' and EN='1' then
      Q <= D;
    end if;
  end process ;
end behavior; 