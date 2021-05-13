-- Pedra (01), Papel (10), Tesoura (11)
-- Cada jogador controla 6 bits (3 jogos)
-- Saida: 10 vit. A, 01 vit. B, 11 empate, 00 estado de espera 

entity jokempo is
  port (
    a: in bit_vector(1 downto 0); --! gesto do jogador A
    b: in bit_vector(1 downto 0); --! gesto do jogador B
    y: out bit_vector(1 downto 0) --! resultado do jogo
  );
end jokempo;

architecture jokempo_arch of jokempo is
begin
    -- A = a(0); B = a(1); C = b(0); D = b(1).

    -- y(1) = AB'C + ABD + BC'D + A'BCD'
    y(1) <= ((a(0) and not a(1)) and b(0)) or
            ((a(0) and a(1)) and b(1))    or
            ((a(1) and not b(0)) and b(1)) or
            ((not a(0) and a(1)) and (b(0) and not b(1))); -- Possivelmente estão invertidos as entradas (0 e 1)
    
    -- y(0) = ACD' + BCD + A'BD + AB'C'D
    y(0) <= ((a(0) and b(0)) and not b(1)) or
            ((a(1) and b(0)) and b(1))     or
            ((not a(0) and a(1)) and b(1)) or
            ((a(0) and not a(1)) and (not b(0) and b(1))); 

end jokempo_arch; -- jokempo

entity melhordetres is
  port(
      resultado1: in bit_vector(1 downto 0); --! resultado do jogo 1
      resultado2: in bit_vector(1 downto 0); --! resultado do jogo 2
      resultado3: in bit_vector(1 downto 0); --! resultado do jogo 3
      z:          out bit_vector(1 downto 0) --! resultado da disputa
  );
  end melhordetres;
  

architecture melhordetres_arch of melhordetres  is
begin

    z <= "00" when (
                    (resultado1 = "00" or resultado2 = "00" or resultado3 = "00")
                    ) else
         "01" when (
                    ((resultado1 = "01" and resultado2 = "01") 
                    or (resultado2 = "01" and resultado3 = "01")) 
                    or (resultado1 = "01" and resultado3 = "01")
                    or (resultado1 = "01" and resultado2 = "11" and resultado3 = "11")
                    or (resultado1 = "11" and resultado2 = "01" and resultado3 = "11")
                    or (resultado1 = "11" and resultado2 = "11" and resultado3 = "01")
                    ) else
         "10" when (
                    ((resultado1 = "10" and resultado2 = "10") 
                    or (resultado2 = "10" and resultado3 = "10")) 
                    or (resultado1 = "10" and resultado3 = "10")
                    or (resultado1 = "10" and resultado2 = "11" and resultado3 = "11")
                    or (resultado1 = "11" and resultado2 = "10" and resultado3 = "11")
                    or (resultado1 = "11" and resultado2 = "11" and resultado3 = "10")
                    ) else
         "11";
  
end melhordetres_arch; -- melhordetres

entity jokempotriplo is
  port (
    a1, a2, a3: in bit_vector(1 downto 0); --! gesto do jogador A para 3 jogos
    b1, b2, b3: in bit_vector(1 downto 0); --! gesto do jogador B para os 3 jogos
    z:          out bit_vector(1 downto 0) --! resultado da disputa
  ) ;
end jokempotriplo; 

-- architecture jokempotriplo_arch of jokempotriplo is

--   signal 

-- begin

-- end jokempotriplo_arch ;